terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.19.0"
    }
  }
}

provider "postgresql" {
  host     = var.host
  port     = var.port
  username = var.username
  password = var.password
}

resource "postgresql_database" "terraform_backend_db" {
  name            = "terraform_backend"
  owner           = var.db_owner
  encoding        = "UTF8"
  tablespace_name = "pg_default"
}

resource "postgresql_database" "terraform_lan_db" {
  name            = "terraform_lan"
  owner           = var.db_owner
  encoding        = "UTF8"
  tablespace_name = "pg_default"
}

resource "postgresql_grant" "terraform_backend_db_grant" {
  database    = postgresql_database.terraform_backend_db.name
  privileges  = ["CONNECT", "CREATE", "TEMPORARY"]
  object_type = "database"
  role        = var.username
}

resource "postgresql_grant" "terraform_lan_db_grant" {
  database    = postgresql_database.terraform_lan_db.name
  privileges  = ["CONNECT", "CREATE", "TEMPORARY"]
  object_type = "database"
  role        = var.username
}
