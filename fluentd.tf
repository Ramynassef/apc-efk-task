resource "kubernetes_manifest" "serviceaccount_kube_logging_fluentd" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "app" = "fluentd"
      }
      "name"      = "fluentd"
      "namespace" = "kube-logging"
    }
  }
}

resource "kubernetes_manifest" "clusterrole_fluentd" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app" = "fluentd"
      }
      "name" = "fluentd"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
          "namespaces",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_fluentd" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRoleBinding"
    "metadata" = {
      "name" = "fluentd"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "ClusterRole"
      "name"     = "fluentd"
    }
    "subjects" = [
      {
        "kind"      = "ServiceAccount"
        "name"      = "fluentd"
        "namespace" = "kube-logging"
      },
    ]
  }
}

resource "kubernetes_manifest" "daemonset_kube_logging_fluentd" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "DaemonSet"
    "metadata" = {
      "labels" = {
        "app" = "fluentd"
      }
      "name"      = "fluentd"
      "namespace" = "kube-logging"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "fluentd"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "fluentd"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name"  = "FLUENT_ELASTICSEARCH_HOST"
                  "value" = "elasticsearch.kube-logging.svc.cluster.local"
                },
                {
                  "name"  = "FLUENT_ELASTICSEARCH_PORT"
                  "value" = "9200"
                },
                {
                  "name"  = "FLUENT_ELASTICSEARCH_SCHEME"
                  "value" = "http"
                },
                {
                  "name"  = "FLUENTD_SYSTEMD_CONF"
                  "value" = "disable"
                },
              ]
              "image" = "fluent/fluentd-kubernetes-daemonset:v1.4.2-debian-elasticsearch-1.1"
              "name"  = "fluentd"
              "resources" = {
                "limits" = {
                  "memory" = "512Mi"
                }
                "requests" = {
                  "cpu"    = "100m"
                  "memory" = "200Mi"
                }
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/var/log"
                  "name"      = "varlog"
                },
                {
                  "mountPath" = "/var/lib/docker/containers"
                  "name"      = "varlibdockercontainers"
                  "readOnly"  = true
                },
              ]
            },
          ]
          "serviceAccount"                = "fluentd"
          "serviceAccountName"            = "fluentd"
          "terminationGracePeriodSeconds" = 30
          "tolerations" = [
            {
              "effect" = "NoSchedule"
              "key"    = "node-role.kubernetes.io/master"
            },
          ]
          "volumes" = [
            {
              "hostPath" = {
                "path" = "/var/log"
              }
              "name" = "varlog"
            },
            {
              "hostPath" = {
                "path" = "/var/lib/docker/containers"
              }
              "name" = "varlibdockercontainers"
            },
          ]
        }
      }
    }
  }
}
