# https://registry.terraform.io/modules/google-terraform-modules/cloudsql/google/latest
/*
module "cloudsql-postgres-ha" {
  source = "git::ssh://git@github.com:google-terraform-modules/terraform-google-cloudsql.git"

  general = {
    name       = "mydatabase"
    env        = "dev"
    region     = "europe-west1"
    db_version = "POSTGRES_9_6"
  }

  instance = {
    zone              = "b"
    #availability_type = "REGIONAL"
  }
}
*/

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
#The slow query log feature designed for MySQL databases enables you to log queries that exceed a predefined time limit. 
#By enabling the "slow_query_log" flag, you can keep an eye on your MySQL database performance, allowing you to identify
#which queries need optimization. Optionally, you can integrate these logs with Google Cloud Operations service (formerly Stackdriver)
#to create and configure alerts that can send you notifications when there are too many slow queries and your database performance is downgraded.
    #database_flags {
    #  name  = "slow_query_log"
    #  value = "on"
    #} 
  }
depends_on = [google_compute_subnetwork.private] 
}

resource "google_sql_user" "users" {
  name       = var.db_username
  instance   = google_sql_database_instance.instance.name
  password   = var.db_password
  depends_on = [google_sql_database_instance.instance]
}