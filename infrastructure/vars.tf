variable "hcloud_token" {
 type = string
 description = "API token for HCloud"
}

variable "cloudflare_token" {
 type = string
 description = "API token for CloudFlare"
}

variable "hcloud_ssh_key_name" {
  type = string
}

variable "cloudflare_zone_name" {
  type = string
}
