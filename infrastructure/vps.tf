resource "hcloud_server" "this" {
  name        = var.cloudflare_zone_name
  image       = "debian-13"
  server_type = "cx23"
  ssh_keys    = [data.hcloud_ssh_key.this.id]
  public_net {
    ipv4_enabled = true
  }
  user_data = templatefile("./scripts/cloud-init.yaml", {
    ssh_key         = data.hcloud_ssh_key.this.public_key,
    domain_name     = var.cloudflare_zone_name,
    github_token    = var.github_pat_token,
    github_username = var.github_username,
    hugo_repo_name  = var.hugo_repo_name
  })
}

data "hcloud_ssh_key" "this" {
  name = var.hcloud_ssh_key_name
}
