terraform {
  backend "s3" {
    endpoint                    = "https://minio.monotremata.xyz"
    bucket                      = "terraform"
    key                         = "terraform.state"
    region                      = "main"
    force_path_style            = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

module "cert-manager" {
  source          = "./modules/cert-manager"
  hetzner_token   = var.hetzner_token
  email           = var.email
  zone_name       = var.zone_name
  dns_common_name = var.dns_common_name
  dns_names       = var.dns_names
}

module "postgresql" {
  source   = "./modules/postgresql"
  host     = "pg.monotremata.xyz"
  password = var.pg_passwd
  username = "terraform"
  db_owner = "rilla"
}

module "dns" {
  source = "./modules/dns"

  # this variable is currently not used because I don't have an IP to whitelist
  # for namecheap's API
  nameservers = [
    "hydrogen.ns.hetzner.com",
    "oxygen.ns.hetzner.com",
    "helium.ns.hetzner.de"
  ]

  domain = "monotremata.xyz"

  caladan = {
    ipv4 = "139.162.137.29"
    ipv6 = "2a01:7e01::f03c:92ff:fea2:5d7c"
    domains = toset([
      "git",
      "gts",
      "kb",
      "keyoxide",
      "matrix",
      "pleroma",
      "pg.caladan",
      "xmpp",
      "proxy.xmpp",
      "upload.xmpp",
      "groups.xmpp",
    ])
  }

  fugu = {
    ipv4 = "217.69.5.52"
    ipv6 = "2001:19f0:6801:1d34:5400:03ff:fe18:7588"
  }

  dkim_pub_key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC3dRTQXNdRNKjM/hnTIQ9d6h4qr7hDkoo3D8ySrV4tEcOC9cCD5fWiUzc560GuWPW5nm/VCDt6gHTGbkwsU/ULO+mjKJtvhZtEJnO4WqVG9Hr2whypODkGM9FSwh0yaWV96OJd51upsNRD/S5fKDMRcl09aBYe2rsn/877re/M0wIDAQAB"
}

module "vps" {
  source = "./modules/vps"
}
