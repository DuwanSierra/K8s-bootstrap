terraform {
  required_version = ">= 1.5.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

locals {
  repo_root                 = abspath("${path.module}/..")
  artifacts_dir             = abspath("${path.module}/artifacts")
  kubeconfig_path           = "${local.artifacts_dir}/kubeconfig.yaml"
  kubeconfig_ready_marker   = "${local.artifacts_dir}/.kubeconfig_ready"
  kubeconfig_ready          = fileexists(local.kubeconfig_ready_marker)
  kubeconfig_placeholder    = abspath("${path.module}/placeholder-kubeconfig.yaml")
  effective_kubeconfig_path = local.kubeconfig_ready ? local.kubeconfig_path : local.kubeconfig_placeholder
  cni_base_dir              = abspath("${local.repo_root}/11.CNI-install")
  cni_path                  = abspath("${local.cni_base_dir}/${var.cni_variant}")
}

provider "kubernetes" {
  config_path    = local.effective_kubeconfig_path
  config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
}

provider "helm" {
  kubernetes {
    config_path    = local.effective_kubeconfig_path
    config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
  }
}

module "k3s" {
  source = "../10.k3s-ha-do"

  do_token        = var.do_token
  ssh_key_name    = var.ssh_key_name
  region          = var.region
  server_count    = var.server_count
  agent_count     = var.agent_count
  flannel_backend = var.flannel_backend
  database_user   = var.database_user
}

locals {
  kubeconfig_endpoint_ip = module.k3s.cluster_summary.api_server_ip
}

resource "null_resource" "artifacts_dir" {
  triggers = {
    path = local.artifacts_dir
  }

  provisioner "local-exec" {
    command = "mkdir -p ${local.artifacts_dir}"
  }
}

resource "null_resource" "fetch_kubeconfig" {
  depends_on = [module.k3s, null_resource.artifacts_dir]

  triggers = {
    api_server_ip = local.kubeconfig_endpoint_ip
    server_ip     = module.k3s.cluster_summary.servers[0].ip_public
  }

  provisioner "local-exec" {
    command = format(
      "bash %s %s %s %s %s %s %s",
      abspath("${path.module}/scripts/fetch-kubeconfig.sh"),
      var.k3s_server_ssh_user,
      module.k3s.cluster_summary.servers[0].ip_public,
      abspath(var.ssh_private_key_path),
      local.kubeconfig_path,
      local.kubeconfig_endpoint_ip,
      local.kubeconfig_ready_marker
    )
  }
}

resource "null_resource" "apply_cni" {
  count      = local.kubeconfig_ready ? 1 : 0
  depends_on = [null_resource.fetch_kubeconfig]

  triggers = {
    cni_variant          = var.cni_variant
    cni_kustomization_id = filesha256("${local.cni_path}/kustomization.yaml")
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = local.kubeconfig_path
    }
    command = format("kubectl apply -k %s", local.cni_path)
  }
}

module "argocd" {
  count  = local.kubeconfig_ready ? 1 : 0
  source = "../20.argo-cd-install"

  argocd_admin_password  = var.argocd_admin_password
  bootstrap_dependency   = length(null_resource.apply_cni) > 0 ? null_resource.apply_cni[0].id : ""
}

module "argocd_apps" {
  count  = local.kubeconfig_ready ? 1 : 0
  source = "../30.apps-of-apps-install"

  argocd_namespace           = var.argocd_namespace
  argocd_root_app_name       = var.argocd_root_app_name
  argocd_root_repo_url       = var.argocd_root_repo_url
  argocd_root_repo_revision  = var.argocd_root_repo_revision
  argocd_root_repo_path      = var.argocd_root_repo_path
  bootstrap_dependency       = length(module.argocd) > 0 ? module.argocd[0].namespace_name : ""
}
