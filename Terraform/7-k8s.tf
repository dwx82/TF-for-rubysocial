# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
# Manages a Google Kubernetes Engine (GKE) cluster. 
resource "google_container_cluster" "primary" {
  name                     = "primary"
  location                 = "us-central1-a" # If you specify a region it will create a cluster in each AZ, it`s prefered but costs a lot.
 
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  #self_link of the Google Compute Engine network to which the cluster is connected.
  network                  = google_compute_network.main.self_link
  
  #self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched.
  subnetwork               = google_compute_subnetwork.private.self_link 
  
  #The logging service that the cluster should write logs to. 
  #Available options include logging.googleapis.com(Legacy Stackdriver), 
  #logging.googleapis.com/kubernetes(Stackdriver Kubernetes Engine Logging), and none. 
  #Defaults to logging.googleapis.com/kubernetes
  logging_service          = "logging.googleapis.com/kubernetes" #Be careful, it can be expensive
  #logging_service          = "none" 
  
  # The monitoring service that the cluster should write metrics to. 
  # Automatically send metrics from pods in the cluster to the Google Cloud Monitoring API. 
  # VM metrics will be collected by Google Compute Engine regardless of this setting Available options include monitoring.googleapis.com(Legacy Stackdriver),
  # monitoring.googleapis.com/kubernetes(Stackdriver Kubernetes Engine Monitoring), and none. Defaults to monitoring.googleapis.com/kubernetes
  monitoring_service       = "none" # "monitoring.googleapis.com/kubernetes" We will deploy Prometheus
  networking_mode          = "VPC_NATIVE" # It`s better than ROUTES, just believe.

  # Optional, for multi-zonal cluster
  node_locations = [
    "us-central1-b"
  ]

  # The status of the HTTP load balancing controller addon, which makes it easy to set up HTTP load balancers for services in a cluster.
  # We will use Ingress
  addons_config {
    http_load_balancing {
      disabled = true
    }
    # The status of the Horizontal Pod Autoscaling addon, which increases or decreases the number of replica pods
    # a replication controller has based on the resource usage of the existing pods. It is enabled by default; set disabled = true to disable.
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "STABLE"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

# https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false #Set to true if you wiil use Bastion host
    master_ipv4_cidr_block  = "172.16.0.0/28" # CIDR range for the Control Plane (k8s master controlled by Google)
  }
    /*
   It is recommended that node pools be created and managed as separate resources as in the example above. 
   This allows node pools to be added and removed without recreating the cluster. 
   Node pools defined directly in the google_container_cluster resource cannot be removed without re-creating the cluster.
    */



  #   Jenkins use case
  #   master_authorized_networks_config {
  #     cidr_blocks {
  #       cidr_block   = "10.0.0.0/18"
  #       display_name = "private-subnet-w-jenkins"
  #     }
  #   }
}
