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

variable "flannel_backend" {
  type        = string
  description = "Backend configurado en el módulo de K3s (usar 'none' si se instalará otro CNI)"
  default     = "none"
}

variable "database_user" {
  type        = string
  description = "Usuario de la base de datos administrada por el módulo K3s"
  default     = "k3s_default_user"
}

variable "cni_variant" {
  type        = string
  description = "Nombre de la carpeta dentro de 11.CNI-install que se aplicará"
  default     = "Calico"

  validation {
    condition     = fileexists(abspath("${path.module}/../11.CNI-install/${var.cni_variant}/kustomization.yaml"))
    error_message = "La carpeta del CNI seleccionado no contiene un kustomization.yaml válido."
  }
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
