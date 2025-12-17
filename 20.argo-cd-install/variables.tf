variable "kubeconfig_path" {
  type        = string
  description = "La ruta al archivo de configuración de kubectl"
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  type        = string
  description = "El contexto de kubectl a usar"
  default     = "minikube"
}

variable "argocd_admin_password" {
  type        = string
  description = "La contraseña del usuario admin de ArgoCD"
  sensitive   = true
}
