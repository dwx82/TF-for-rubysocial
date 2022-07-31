# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
# This snippet creates a service account in a project. I do my best to follow the best practice 
resource "google_service_account" "kubernetes" {
  account_id = "kubernetes"
  display_name = "k8s Service Account"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
# https://cloud.google.com/kubernetes-engine/docs/concepts/node-pools
# Manages a node pool in a Google Kubernetes Engine (GKE) cluster separately from the cluster control plane.

# w/o autoscalling
resource "google_container_node_pool" "general" {
  name       = "general"
  cluster    = google_container_cluster.primary.id
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
autoscaling {
    min_node_count = 0
    max_node_count = 10
  }
  node_config {
    preemptible  = false
    machine_type = var.instance_type

    labels = {
      role = "general"
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

/*
Preemptible VMs are Compute Engine VM instances that last a maximum of 24 hours, and provide no availability guarantees.
Preemptible VMs offer similar functionality to Spot VMs, but only last up to 24 hours after creation.
# w/autoscalling very cheap nodes
resource "google_container_node_pool" "spot" {
  name    = "spot"
  cluster = google_container_cluster.primary.id

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 10
  }

  node_config {
    preemptible  = true
    machine_type = var.instance_type

    labels = {
      team = "devops"
    }
# must have taints to avoid accident scheduling
    taint {
      key    = "instance_type"
      value  = "spot"
      effect = "NO_SCHEDULE"
    }

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
*/

