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
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = ">= 1.15.2"
    }
    linode = {
      source  = "linode/linode"
      version = ">= 1.29.0"
    }
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = ">=2.2.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.19.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "minio" {
  minio_server = "minio.monotremata.xyz:443"
  minio_user   = "terraform"
  minio_ssl    = true
}

provider "postgresql" {
  username = "terraform"
  password = var.pg_passwd
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

module "minio" {
  source              = "./modules/minio"
  minio_root_user     = var.minio_root_user
  minio_root_password = var.minio_root_password
  minio_url           = "minio.monotremata.xyz"
  minio_console_url   = "minio-console.monotremata.xyz"
  minio_host_path     = "/mnt/k3s_volumes/minio"
}

module "minio_buckets" {
  source = "./modules/minio_buckets"
  providers = {
    minio = minio
  }
  depends_on = [module.minio]
}
