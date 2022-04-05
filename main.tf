resource "random_password" "password" {
  // Create a new password with special chars and 16 characters
  length  = 16
  special = true
}

resource "google_sql_database_instance" "master" {
  // Create a new sql database with variables.tf content
  name                = var.instance_name
  database_version    = var.database_version
  region              = var.region
  deletion_protection = false
  // We allow internet access only for lab purpose
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "internet"
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_user" "users" {
  // Create the database user
  name     = var.username
  instance = var.instance_name
  password = random_password.password
}

resource "vault_generic_secret" "example" {
  // Put the password in vault
  path      = "secret/lolo"
  data_json = <<EOT
  {
    "user" = "${var.username}",
    "password" = "${random_password.password}"
  }
  EOT
}

