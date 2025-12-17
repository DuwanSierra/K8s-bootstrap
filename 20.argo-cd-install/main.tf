resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

module "argocd" {
  source  = "aigisuk/argocd/kubernetes"
  version = "0.2.7"

  namespace    = kubernetes_namespace.argocd.metadata[0].name
  release_name = "argocd"

  insecure       = true
  enable_dex     = false
  admin_password = var.argocd_admin_password
}
