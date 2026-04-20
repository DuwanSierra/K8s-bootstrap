data "digitalocean_ssh_key" "this" {
  name = var.ssh_key_name
}

module "k3s" {
  source = "github.com/DuwanSierra/HA-K3s-Terraform-DO"

  do_token             = var.do_token
  ssh_key_fingerprints = [data.digitalocean_ssh_key.this.fingerprint]

  region        = var.region
  server_count  = var.server_count
  agent_count   = var.agent_count
  database_user = var.database_user
  agent_size    = var.agent_size
  cni_provider  = var.cni_provider
}
