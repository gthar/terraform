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
