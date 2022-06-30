resource "kubernetes_manifest" "namespace_kube_logging" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "kube-logging"
    }
  }
}
