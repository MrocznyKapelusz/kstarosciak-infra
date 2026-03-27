terraform {
  backend "s3" {
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "= 1.60.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "= 5.18"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "hcloud" {
  token = var.hcloud_token
}
