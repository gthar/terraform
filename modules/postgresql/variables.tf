variable "host" {
  type        = string
  description = "postgresql host"
}

variable "port" {
  type        = number
  description = "postgresql post"
  default     = 5432
}

variable "password" {
  type        = string
  description = "postgresql password"
  sensitive   = true
}

variable "username" {
  type        = string
  description = "postgresql username"
  sensitive   = true
}

variable "db_owner" {
  type        = string
  description = "postgresql database owner"
}
