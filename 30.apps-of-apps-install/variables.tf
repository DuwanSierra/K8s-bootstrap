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

variable "cni_np_use_case" {
  type        = string
  description = <<-EOT
    Caso de uso de Network Policies activo. Determina el overlay de NP desplegado en cni-np-test.
    Valores válidos: "zero-trust" | "multi-tier" | "egress-block" | "" (deshabilitado)
    Flannel siempre queda en "" (no soporta NetworkPolicies).
    Cambiar este valor hace que ArgoCD pruneé las NPs del caso anterior y aplique el nuevo.
  EOT
  default     = ""

  validation {
    condition     = contains(["", "zero-trust", "multi-tier", "egress-block"], var.cni_np_use_case)
    error_message = "cni_np_use_case debe ser uno de: '' | 'zero-trust' | 'multi-tier' | 'egress-block'."
  }
}

