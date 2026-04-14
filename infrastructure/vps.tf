resource "hcloud_server" "this" {
  name        = var.cloudflare_zone_name
  image       = "debian-13"
  server_type = "cx23"
  ssh_keys = [data.hcloud_ssh_key.this.id] 
  public_net {
    ipv4_enabled = true
  }
  user_data = templatefile("./scripts/cloud-init.sh",{ ssh_key = data.hcloud_ssh_key.this.public_key })
}

data "hcloud_ssh_key" "this" {
  name = var.hcloud_ssh_key_name
}
