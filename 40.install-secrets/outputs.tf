output "secret_name" {
  description = "Nombre del secret creado para credenciales Git"
  value       = kubernetes_secret_v1.cni_results_git_credentials.metadata[0].name
}

output "secret_namespace" {
  description = "Namespace donde se creo el secret"
  value       = kubernetes_secret_v1.cni_results_git_credentials.metadata[0].namespace
}
