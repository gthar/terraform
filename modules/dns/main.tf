terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">= 1.29.0"
    }
    namecheap = {
      source  = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
  }
}
