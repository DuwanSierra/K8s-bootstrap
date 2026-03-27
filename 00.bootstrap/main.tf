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

  argocd_ready_marker = "${local.artifacts_dir}/.argocd_ready"
  argocd_ready        = fileexists(local.argocd_ready_marker)
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

  do_token      = var.do_token
  ssh_key_name  = var.ssh_key_name
  region        = var.region
  server_count  = var.server_count
  agent_count   = var.agent_count
  database_user = var.database_user
  agent_size    = var.agent_size
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

module "argocd" {
  count  = local.kubeconfig_ready ? 1 : 0
  source = "../20.argo-cd-install"

  argocd_admin_password = var.argocd_admin_password
}

resource "null_resource" "mark_argocd_ready" {
  count      = local.kubeconfig_ready ? 1 : 0
  depends_on = [module.argocd]

  triggers = {
    argocd_namespace = length(module.argocd) > 0 ? module.argocd[0].namespace_name : ""
  }

  provisioner "local-exec" {
    command = "touch ${local.argocd_ready_marker}"
  }
}

module "argocd_apps" {
  count      = local.argocd_ready ? 1 : 0
  depends_on = [null_resource.mark_argocd_ready]
  source     = "../30.apps-of-apps-install"

  argocd_namespace          = var.argocd_namespace
  argocd_root_app_name      = var.argocd_root_app_name
  argocd_root_repo_url      = var.argocd_root_repo_url
  argocd_root_repo_revision = var.argocd_root_repo_revision
  argocd_root_repo_path     = var.argocd_root_repo_path
  bootstrap_dependency      = length(module.argocd) > 0 ? module.argocd[0].namespace_name : ""
}

module "install_secrets" {
  count      = local.argocd_ready ? 1 : 0
  depends_on = [module.argocd_apps]
  source     = "../40.install-secrets"

  git_user  = var.cni_results_git_user
  git_token = var.cni_results_git_token
}
