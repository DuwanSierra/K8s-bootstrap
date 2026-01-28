variable "argocd_admin_password" {
  type        = string
  description = "La contraseña del usuario admin de ArgoCD"
  sensitive   = true
}

variable "bootstrap_dependency" {
  type        = string
  description = "Token sin uso funcional, solo para forzar dependencias externas en el módulo"
  default     = ""
}
