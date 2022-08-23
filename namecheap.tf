// https://registry.terraform.io/providers/namecheap/namecheap/latest/docs

variable "caladan-ip" {
  type = string
  default = "139.162.137.29"
}

variable "caladan-hostnames" {
  type = set(string)
  default = ["@"]
}

provider "namecheap" {
  user_name = "gthar"
  api_user = "gthar"
  client_ip = var.caladan-ip
  use_sandbox = false
}

resource "namecheap_domain_records" "monotremata-xyz" {
  domain = "monotremata.xyz"
  mode = "MERGE"  // maybe eventually move to OVERWRITE

  dynamic "record" {
    for_each = var.caladan-hostnames
    content {
      hostname = record.value
      type = "A"
      address = var.caladan-ip
    }
  }
}
