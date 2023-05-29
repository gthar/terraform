variable "hetzner_token" {
  type        = string
  description = "hetzner dns token"
  sensitive   = true
}

variable "group_name" {
  type        = string
  description = "group name to be used for DNS webhook"
  default     = "dns.hetzner.cloud"
}

variable "zone_name" {
  type        = string
  description = "hetzner domain zone"
}

variable "cert_manager_version" {
  type        = string
  description = "cert-manager version to install"
  default     = "v1.12.0"
}

variable "email" {
  type        = string
  description = "email for letsencrypt registration"
}

variable "letsencrypt_servers" {
  type = object({
    staging = string
    prod    = string
  })
  description = "urls for the letsencrypt servers"
  default = {
    staging = "https://acme-staging-v02.api.letsencrypt.org/directory"
    prod    = "https://acme-v02.api.letsencrypt.org/directory"
  }
}

variable "hetzner_dns_api" {
  type        = string
  description = "endpoint for the hetnzer dns api"
  default     = "https://dns.hetzner.com/api/v1"
}

variable "dns_common_name" {
  type        = string
  description = "common name for the certificate"
}

variable "dns_names" {
  type        = list(string)
  description = "list of domains for the certificate"
}
