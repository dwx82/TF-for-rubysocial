#=============================k8s==================================
variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "prod-357409"
}
variable "instance_type" {
  description = "The node instance type"
  default     = "e2-small"
}
variable "region" {
  description = "The region to host the cluster in"
  default     = "us-central1"
}
variable "cluster_config_path" {
  type        = string
  description = "The location where this cluster's kubeconfig will be saved to."
  default     = "~/.kube/config"
}
#==============================db==================================
variable "name" {
  type        = string
  default     = "proddb"
  description = "DB instance name"
}
variable "db_instance_type" {
  description = "The node instance type"
  default     = "db-custom-1-3840"
}
variable "database_version" {
  type        = string
  default     = "POSTGRES_13"
  description = "Database version -> MYSQL_5_6, POSTGRES_12, SQLSERVER_2017_STANDARD..."
}
variable "db_username" {
  description = "Database administrator username"
  default     = "postgres"
  type        = string
  sensitive   = true
}
variable "db_password" {
  description = "Database administrator password"
  default     = "postgres"
  type        = string
  sensitive   = true
}
#==========================namespaces==============================
variable "ingress_nginx_namespace" {
  type        = string
  description = "The nginx ingress namespace (it will be created if needed)."
  default     = "ingress"
}
variable "prometheus_grafana_namespace" {
  type        = string
  description = "The prometheus stack namespace (it will be created if needed)."
  default     = "monitoring"
}
#=============================ingress==============================
variable "ingress_nginx_helm_version" {
  type        = string
  description = "The Helm version for the nginx ingress controller."
  default     = "4.2.0"
}
variable "cert_manager_version" {
  type        = string
  description = "Cert manager version for HTTPS."
  default     = "v1.9.0"
}
#=============================bucket===============================
variable "bucket_name" {
  type        = string
  description = "Bucket name for static files. Autocreate "
  default     = "megateam_bucket_production"
}
variable "folder_path" {
 type        = string
 description = "Path to your folder"
 default     = "~/test"
}