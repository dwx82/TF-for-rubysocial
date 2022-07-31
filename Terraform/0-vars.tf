#=============================k8s==================================
variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "staging-357319"
}
variable "instance_type" {
  description = "The node instance type"
  default     = "e2-standard-2"
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
  default     = "stagingdb"
  description = "DB instance name"
}
variable "db_instance_type" {
  description = "The node instance type"
  default     = "db-g1-small"
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
variable "sonarqube_namespace" {
  type        = string
  description = "The sonarqube stack namespace (it will be created if needed)."
  default     = "sonarqube"
}
variable "letsencrypt_namespace" {
  type        = string
  description = "The letsencrypt namespace (it will be created if needed)."
  default     = "letsencrypt"
}
#=============================ingress==============================
variable "ingress_nginx_helm_version" {
  type        = string
  description = "The Helm version for the nginx ingress controller."
  default     = "4.2.0"
}
variable "cert_manager_version" {
  type        = string
  description = "The letsencrypt version ."
  default     = "v1.9.0"
}
#=============================bucket===============================
variable "bucket_name" {
  type        = string
  description = "The Helm version for the nginx ingress controller."
  default     = "megateam_bucket_staging"
}
variable "folder_path" {
 type        = string
 description = "Path to your folder"
 default     = "~/test"
}