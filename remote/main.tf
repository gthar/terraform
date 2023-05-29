terraform {
  backend "pg" {}
  required_providers {
    namecheap = {
      source  = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
    linode = {
      source  = "linode/linode"
      version = ">= 1.29.0"
    }
    vultr = {
      source  = "vultr/vultr"
      version = "2.11.4"
    }
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = ">=2.2.0"
    }
  }
}

provider "namecheap" {
  user_name   = "gthar"
  api_user    = "gthar"
  client_ip   = "139.162.137.29" // caladan's public IP
  use_sandbox = false
}

provider "vultr" {
}

module "dns" {
  source = "../modules/dns"

  #nameservers = [
  #  "ns1.linode.com",
  #  "ns2.linode.com",
  #  "ns3.linode.com",
  #  "ns4.linode.com",
  #  "ns5.linode.com"
  #]

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
  source = "../modules/vps"
}
