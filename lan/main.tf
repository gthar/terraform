terraform {
  backend "pg" {}
  required_providers {
  }
}

module "cert-manager" {
  source          = "../modules/cert-manager"
  hetzner_token   = var.hetzner_token
  email           = var.email
  zone_name       = var.zone_name
  dns_common_name = var.dns_common_name
  dns_names       = var.dns_names
}
