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

