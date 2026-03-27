resource "hcloud_server" "this" {
  name        = "cloud-resume-challenge"
  image       = "rocky-10"
  server_type = "cx23"
  ssh_keys = [data.hcloud_ssh_key.this.id] 
  public_net {
    ipv4_enabled = true
  }
}

data "hcloud_ssh_key" "this" {
  name = "cloud-resume-challenge"
}
