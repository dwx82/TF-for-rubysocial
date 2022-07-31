# https://registry.terraform.io/modules/google-terraform-modules/cloudsql/google/latest

resource "google_sql_database_instance" "instance" {
  name             = var.name
  database_version = var.database_version
  region           = var.region

  settings {
    tier = var.db_instance_type
    backup_configuration {
    enabled    = true
    start_time = "02:00"
    }
    availability_type = "REGIONAL"
    disk_size         = "20"
    database_flags {
      name  = "log_connections"
      value = "on"
    }

  }
depends_on = [google_compute_subnetwork.private] 
}

resource "google_sql_user" "users" {
  name       = var.db_username
  instance   = google_sql_database_instance.instance.name
  password   = var.db_password
  depends_on = [google_sql_database_instance.instance]
}