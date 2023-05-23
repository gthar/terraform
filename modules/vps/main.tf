terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">= 1.29.0"
    }
    vultr = {
      source  = "vultr/vultr"
      version = "2.11.4"
    }
  }
}
