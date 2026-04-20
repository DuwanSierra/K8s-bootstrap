variable "do_token" {
  type      = string
  sensitive = true
}
variable "ssh_key_name" {
  type        = string
  description = "Nombre EXACTO de tu SSH Key en DigitalOcean (Control Panel)"
}
# Opcionales típicos
variable "region" {
  type    = string
  default = "fra1"
}
variable "server_count" {
  type    = number
  default = 1
}
variable "agent_count" {
  type    = number
  default = 1
}
variable "database_user" {
  type    = string
  default = "k3s_default_user"
}

variable "agent_size" {
  type = string
}

variable "cni_provider" {
  type        = string
  description = "CNI plugin: flannel, calico, cilium o antrea"
  default     = "flannel"
}