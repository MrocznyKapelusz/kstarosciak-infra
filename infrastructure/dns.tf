data "cloudflare_zone" "this" {
 filter = {
   name = var.cloudflare_zone_name
 }
}

resource "cloudflare_dns_record" "hcloud_server" {
  zone_id = data.cloudflare_zone.this.zone_id
  name = "@"
  ttl = 3600
  type = "A"
  content = "${hcloud_server.this.ipv4_address}"
}
