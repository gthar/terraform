provider "namecheap" {
  user_name   = "gthar"
  api_user    = "gthar"
  client_ip   = var.caladan.ipv4 // caladan's public IP
  use_sandbox = false
}

resource "namecheap_domain_records" "namecheap-monotremata-xyz" {
  domain      = var.domain
  mode        = "OVERWRITE"
  nameservers = var.nameservers
}
