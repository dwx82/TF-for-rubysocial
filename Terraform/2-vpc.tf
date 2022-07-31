# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
# service = The service to enable.
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "main" {
  name                            = "main"
/*
The network-wide routing mode to use. If set to REGIONAL,
this network's cloud routers will only advertise routes with subnetworks of this network in the same region as the router. 
If set to GLOBAL, this network's cloud routers will advertise routes with all subnetworks of this network, across regions.
*/
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false # route to the Internet

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}
