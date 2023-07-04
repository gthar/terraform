variable "minio_image" {
  type        = string
  description = "image used for minio"
  default     = "minio/minio:latest"
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

variable "minio_port" {
  type        = number
  description = "http port used by minio"
  default     = 9000
}

variable "minio_console_port" {
  type        = number
  description = "http port used by minio's console"
  default     = 9001
}

variable "minio_url" {
  type        = string
  description = "minio url"
}

variable "minio_console_url" {
  type        = string
  description = "minio console url"
}

variable "minio_host_path" {
  type        = string
  description = "host path for the volume to be used as storage for minio"
}

variable "minio_storage_capacity" {
  type        = string
  description = "capacity for minio's storage"
  default     = "10Gi"
}
