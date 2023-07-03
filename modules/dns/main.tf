terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">= 1.29.0"
    }
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = ">=2.2.0"
    }
  }
}
