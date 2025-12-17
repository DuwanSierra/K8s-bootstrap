resource "kubernetes_manifest" "argocd_root_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.argocd_root_app_name
      namespace = var.argocd_namespace
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      project = "default"

      source = {
        repoURL        = var.argocd_root_repo_url
        targetRevision = var.argocd_root_repo_revision
        path           = var.argocd_root_repo_path
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.argocd_namespace
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}
