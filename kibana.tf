resource "kubernetes_manifest" "service_kube_logging_kibana" {
  depends_on = [kubernetes_manifest.namespace_kube_logging]
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "labels" = {
        "app" = "kibana"
      }
      "name"      = "kibana"
      "namespace" = "kube-logging"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 5601
        },
      ]
      "selector" = {
        "app" = "kibana"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_kube_logging_kibana" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "kibana"
      }
      "name"      = "kibana"
      "namespace" = "kube-logging"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "kibana"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "kibana"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name"  = "ELASTICSEARCH_URL"
                  "value" = "http://elasticsearch:9200"
                },
              ]
              "image" = "docker.elastic.co/kibana/kibana:7.2.0"
              "name"  = "kibana"
              "ports" = [
                {
                  "containerPort" = 5601
                },
              ]
              "resources" = {
                "limits" = {
                  "cpu" = "100m"
                }
                "requests" = {
                  "cpu" = "100m"
                }
              }
            },
          ]
        }
      }
    }
  }
}
