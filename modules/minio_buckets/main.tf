terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 1.15.2"
    }
  }
}

resource "minio_s3_bucket" "state_terraform_s3" {
  bucket = "terraform"
  acl    = "private"
}

resource "minio_s3_bucket" "nextcloud_bucket" {
  bucket = "nextcloud"
  acl    = "private"
}
