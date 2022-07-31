# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall

resource "null_resource" "get_credentials" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials primary -z=us-central1"
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

/*# Deploy letsencryprt
#https://gist.github.com/TylerWanner/8b38494bea6535fa10936c5a81678c78
resource "helm_release" "letsencryprt" {
  name             = "cm"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version
  namespace        = "cert-manager"
  create_namespace = true

depends_on = [helm_release.ingress_nginx]
}*/

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

#The recommended approach is to use the manifests attribute and a for_each expression to apply the found manifests.
#This ensures that any additional yaml documents or removals do not cause a large amount of terraform changes.
# https://github.com/jetstack/cert-manager/releases/download/${var.cert_manager_version}/cert-manager.yaml
# Deploy letsencryprt
/*data "http" "manifestfile" {
  url = "https://github.com/jetstack/cert-manager/releases/download/v1.9.0/cert-manager.yaml"
}
data "kubectl_file_documents" "manifestbody" {
  content = data.http.manifestfile.body
  depends_on = [data.http.manifestfile]
}
resource "kubectl_manifest" "mymanifest" {
  for_each  = data.kubectl_file_documents.manifestbody.manifests
  yaml_body = each.value

  depends_on = [helm_release.ingress_nginx]
}*/


# ingress rule
# https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/kubectl_file_documents
/*data "kubectl_file_documents" "docs" {
    content    = file("tlsingress.yaml")

    depends_on = [helm_release.ingress_nginx]
}

resource "kubectl_manifest" "test" {
    for_each   = data.kubectl_file_documents.docs.manifests
    yaml_body  = each.value 

    depends_on = [data.kubectl_file_documents.docs]   
}*/

data "kubectl_file_documents" "docs" {
    content = file("tlsingress.yaml")
}

resource "kubectl_manifest" "test" {
    count     = length(data.kubectl_file_documents.docs.documents)
    yaml_body = element(data.kubectl_file_documents.docs.documents, count.index)

    depends_on = [kubectl_manifest.https]

}

data "kubectl_file_documents" "https" {
    content = file("cert-manager.yaml")
}

resource "kubectl_manifest" "https" {
    count     = length(data.kubectl_file_documents.https.documents)
    yaml_body = element(data.kubectl_file_documents.https.documents, count.index)

    depends_on = [helm_release.ingress_nginx]

}

# https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/kubectl_manifest
