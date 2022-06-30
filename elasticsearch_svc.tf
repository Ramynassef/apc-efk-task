resource "kubernetes_manifest" "service_kube_logging_elasticsearch" {
  depends_on = [kubernetes_manifest.namespace_kube_logging]
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "labels" = {
        "app" = "elasticsearch"
      }
      "name"      = "elasticsearch"
      "namespace" = "kube-logging"
    }
    "spec" = {
      "clusterIP" = "None"
      "ports" = [
        {
          "name" = "rest"
          "port" = 9200
        },
        {
          "name" = "inter-node"
          "port" = 9300
        },
      ]
      "selector" = {
        "app" = "elasticsearch"
      }
    }
  }
}
