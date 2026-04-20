variable "argocd_namespace" {
  type    = string
  default = "argocd"
}

variable "argocd_root_app_name" {
  type    = string
  default = "root-apps"
}

variable "argocd_root_repo_url" {
  type        = string
  description = "Repositorio GitOps donde vive la app raíz de ArgoCD"
}

variable "argocd_root_repo_revision" {
  type    = string
  default = "main"
}

variable "argocd_root_repo_path" {
  type        = string
  description = "Ruta dentro del repo donde está el Kustomize/Helm/manifests de la app raíz"
  default     = "apps"
}

variable "bootstrap_dependency" {
  type        = string
  description = "Token opcional para encadenar este módulo a otros despliegues"
  default     = ""
}

variable "cni_provider" {
  type        = string
  description = "CNI plugin activo; determina qué overlay de Kustomize usan los apps de pruebas"
  default     = "flannel"
}

