/*# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
# Optional block
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
*/
resource "null_resource" "get_credentials" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials primary -z=us-central1-a"
  }
  depends_on = [google_container_node_pool.general]
}

resource "helm_release" "prometheus" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = var.prometheus_grafana_namespace
  create_namespace = true

  depends_on = [null_resource.get_credentials]
}
/*
resource "helm_release" "sonarqube" {
  name             = "sonar"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "sonarqube"
  namespace        = var.sonarqube_namespace
  create_namespace = true

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
  set {
    name  = "service.ports.http	"
    value = "80"
  }
  set {
    name  = "service.ports.elastic"
    value = "9001"
  }
  set {
    name  = "service.nodePorts.http"
    value = "80"
  }
  set {
    name  = "service.nodePorts.elastic"
    value = "9001"
  }

  depends_on = [null_resource.get_credentials]
}
*/
# Deploy nginx ingress controller 
resource "helm_release" "ingress_nginx" {
  name             = "my-ingress"
  #repository       = "https://charts.bitnami.com/bitnami"
  #chart            = "nginx-ingress-controller"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.ingress_nginx_helm_version
  namespace        = var.ingress_nginx_namespace
  create_namespace = true

  values = [file("nginx-values.yaml")]

depends_on = [null_resource.get_credentials]
}
/*
resource "helm_release" "letsencrypt" {
  name             = "cert-manager"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "cert-manager"
  namespace        = var.letsencrypt_namespace
  create_namespace = true

depends_on = [helm_release.ingress_nginx]
}
#The recommended approach is to use the manifests attribute and a for_each expression to apply the found manifests.
#This ensures that any additional yaml documents or removals do not cause a large amount of terraform changes.

# Deploy letsencryprt
data "http" "manifestfile" {
  url = "https://github.com/jetstack/cert-manager/releases/download/${var.cert_manager_version}/cert-manager.yaml"
}
data "kubectl_file_documents" "manifestbody" {
  content = data.http.manifestfile.body
}
resource "kubectl_manifest" "mymanifest" {
  #yaml_body = data.http.manifestfile.body
  for_each  = data.kubectl_file_documents.manifestbody.manifests
  yaml_body = each.value

  depends_on = [helm_release.ingress_nginx]
}*/

# ingress rule
# https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/kubectl_file_documents

data "kubectl_file_documents" "https" {
    content = file("cert-manager.yaml")
}

resource "kubectl_manifest" "https" {
    count     = length(data.kubectl_file_documents.https.documents)
    yaml_body = element(data.kubectl_file_documents.https.documents, count.index)

    depends_on = [helm_release.ingress_nginx]

}

data "kubectl_file_documents" "docs" {
    content = file("tlsingress.yaml")
}

resource "kubectl_manifest" "test" {
    count     = length(data.kubectl_file_documents.docs.documents)
    yaml_body = element(data.kubectl_file_documents.docs.documents, count.index)

    depends_on = [kubectl_manifest.https]

}

# Deploy nginx ingress service 
# https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/kubectl_manifest
