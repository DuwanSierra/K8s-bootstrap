resource "kubernetes_secret_v1" "cni_results_git_credentials" {
  metadata {
    name      = var.secret_name
    namespace = var.secret_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  type = "Opaque"

  data = {
    GIT_USER  = var.git_user
    GIT_TOKEN = var.git_token
  }
}
