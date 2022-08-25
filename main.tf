terraform {
  backend "pg" {}
  required_providers {
    namecheap = {
      source = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
    linode = {
      source = "linode/linode"
      version = ">= 1.29.0"
    }
    vultr = {
      source = "vultr/vultr"
      version = "2.11.4"
    }
  }
}

provider "namecheap" {
  user_name   = "gthar"
  api_user    = "gthar"
  client_ip   = "139.162.137.29"  // caladan's public IP
  use_sandbox = false
}

provider "linode" {
}

provider "vultr" {
}
