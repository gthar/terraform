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
  }
}
