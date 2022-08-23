// https://registry.terraform.io/providers/namecheap/namecheap/latest/docs

variable "caladan-ips" {
  type = object({
    v4 = string
    v6 = string
  })
  default = {
    v4 = "139.162.137.29"
    v6 = "2a01:7e01::f03c:92ff:fea2:5d7c"
  }
}

variable "caladan-hostnames" {
  type = set(string)
  default = ["@"]
}

provider "namecheap" {
  user_name = "gthar"
  api_user = "gthar"
  client_ip = var.caladan-ips.v4
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
      address = var.caladan-ips.v4
    }
  }

  dynamic "record" {
    for_each = var.caladan-hostnames
    content {
      hostname = record.value
      type = "AAAA"
      address = var.caladan-ips.v6
    }
  }

}
