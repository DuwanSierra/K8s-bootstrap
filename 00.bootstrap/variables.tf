variable "do_token" {
  type        = string
  description = "DigitalOcean Personal Access Token"
  sensitive   = true
}

variable "ssh_key_name" {
  type        = string
  description = "Nombre exacto de la clave SSH registrada en DigitalOcean"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Ruta local a la clave privada usada para acceder a los nodos"
}

variable "k3s_server_ssh_user" {
  type        = string
  description = "Usuario SSH para conectarse a los servidores creados"
  default     = "root"
}

variable "region" {
  type        = string
  description = "Región de DigitalOcean donde se desplegará el clúster"
  default     = "nyc3"
}

variable "server_count" {
  type        = number
  description = "Cantidad de nodos server (control plane)"
  default     = 1
}

variable "agent_count" {
  type        = number
  description = "Cantidad de nodos agent (workers)"
  default     = 1
}
variable "database_user" {
  type        = string
  description = "Usuario de la base de datos administrada por el módulo K3s"
  default     = "k3s_default_user"
}
variable "kubeconfig_context" {
  type        = string
  description = "Contexto de kubeconfig a usar; dejar vacío para usar el contexto embebido"
  default     = ""
}

variable "kubeconfig_use_server_ip" {
  type        = bool
  description = "Si es true, el kubeconfig apuntará al IP público del primer server en lugar del Load Balancer"
  default     = true
}

variable "argocd_admin_password" {
  type        = string
  description = "Contraseña del usuario admin de Argo CD"
  sensitive   = true
}

variable "argocd_namespace" {
  type        = string
  description = "Namespace donde vive Argo CD"
  default     = "argocd"
}

variable "argocd_root_app_name" {
  type        = string
  description = "Nombre del Application raíz"
  default     = "root-apps"
}

variable "argocd_root_repo_url" {
  type        = string
  description = "Repositorio GitOps que contiene la app raíz"
}

variable "argocd_root_repo_revision" {
  type        = string
  description = "Branch o tag del repo GitOps"
  default     = "main"
}

variable "argocd_root_repo_path" {
  type        = string
  description = "Ruta relativa dentro del repo para la app raíz"
  default     = "apps"
}

variable "cni_results_git_user" {
  type        = string
  description = "Usuario Git para crear el secret de resultados CNI"
  sensitive   = true
}

variable "cni_results_git_token" {
  type        = string
  description = "Token PAT Git para crear el secret de resultados CNI"
  sensitive   = true
}

variable "agent_size" {
  type        = string
  description = "Tamaño del droplet para los agentes"
}

variable "cni_provider" {
  type        = string
  description = "CNI plugin a instalar: flannel (nativo k3s), calico, cilium o antrea"
  default     = "flannel"
  validation {
    condition     = contains(["flannel", "calico", "cilium", "antrea"], var.cni_provider)
    error_message = "CNI válidos: flannel, calico, cilium, antrea."
  }
}
