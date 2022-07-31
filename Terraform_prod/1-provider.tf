# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.cluster_config_path)
  }
}
# https://www.terraform.io/language/settings/backends/gcs
# Warning! It is highly recommended that you enable Object Versioning on the GCS bucket
# to allow for state recovery in the case of accidental deletions and human error.
terraform {
  backend "gcs" {
    bucket = "prodtfstate"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    # For helm
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
  }
  # For letsencrypt
  acme = {
      source  = "vancluever/acme"
      version = "~> 2.5.3"
    }
 }
}