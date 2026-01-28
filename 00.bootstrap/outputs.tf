output "kubeconfig_path" {
  description = "Ruta local del kubeconfig generado a partir del servidor K3s"
  value       = local.kubeconfig_path
}

output "cluster_summary" {
  description = "Resumen del clúster creado por el módulo de K3s"
  value       = module.k3s.cluster_summary
}
