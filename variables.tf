variable "hetzner_token" {
  type        = string
  description = "hetzner dns token"
  sensitive   = true
}

variable "email" {
  type        = string
  description = "email for letsencrypt registration"
  default     = "rilla@monotremata.xyz"
}

variable "zone_name" {
  type        = string
  description = "hetzner domain zone"
  default     = "monotremata.xyx"
}

variable "dns_common_name" {
  type        = string
  default     = "monotremata.xyz"
  description = "common name for the certificate"
}

variable "dns_names" {
  type        = list(string)
  description = "list of domains for the certificate"
  default = [
    "monotremata.xyz",
    "*.monotremata.xyz",
    "*.suricata.monotremata.xyz",
  ]
}

variable "pg_passwd" {
  type        = string
  sensitive   = true
  description = "postgresql password"
}

variable "minio_root_user" {
  type        = string
  description = "minio root username"
  sensitive   = true
}

variable "minio_root_password" {
  type        = string
  description = "minio root password"
  sensitive   = true
}
