variable "domain" {
  type        = string
  description = "main domain"
}

variable "caladan" {
  type = object({
    ipv4    = string
    ipv6    = string
    domains = set(string)
  })
  description = "configuration values specific to caladan (my Alpine VPS hosted on linode)"
}

variable "fugu" {
  type = object({
    ipv4 = string
    ipv6 = string
  })
  description = "configuration values specific to fugu (my OpenBSD VPS hosted on vultr)"
}

variable "dkim_pub_key" {
  type        = string
  description = "dkim public key"
}

variable "nameservers" {
  type = list(string)
  description = "dns nameservers to use"
}
