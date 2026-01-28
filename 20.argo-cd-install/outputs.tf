output "namespace_name" {
  description = "Nombre del namespace creado para Argo CD"
  value       = kubernetes_namespace.argocd.metadata[0].name
}
