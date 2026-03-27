variable "secret_namespace" {
  type        = string
  description = "Namespace donde se creara el secret"
  default     = "cni-test"
}

variable "secret_name" {
  type        = string
  description = "Nombre del secret con credenciales Git"
  default     = "cni-results-git-credentials"
}

variable "git_user" {
  type        = string
  description = "Usuario Git para autenticacion del repo de resultados CNI"
  sensitive   = true
}

variable "git_token" {
  type        = string
  description = "Token PAT Git para autenticacion del repo de resultados CNI"
  sensitive   = true
}
