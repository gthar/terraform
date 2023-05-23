provider "namecheap" {
  user_name   = "gthar"
  api_user    = "gthar"
  client_ip   = "139.162.137.29" // caladan's public IP
  use_sandbox = false
}

resource "namecheap_domain_records" "namecheap-monotremata-xyz" {
  domain = "monotremata.xyz"
  mode   = "OVERWRITE"
  nameservers = [
    "ns1.linode.com",
    "ns2.linode.com",
    "ns3.linode.com",
    "ns4.linode.com",
    "ns5.linode.com"
  ]
}
