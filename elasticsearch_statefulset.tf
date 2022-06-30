resource "kubernetes_manifest" "statefulset_kube_logging_es_cluster" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "StatefulSet"
    "metadata" = {
      "name"      = "es-cluster"
      "namespace" = "kube-logging"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "elasticsearch"
        }
      }
      "serviceName" = "elasticsearch"
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "elasticsearch"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name"  = "cluster.name"
                  "value" = "k8s-logs"
                },
                {
                  "name" = "node.name"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "metadata.name"
                    }
                  }
                },
                {
                  "name"  = "discovery.seed_hosts"
                  "value" = "es-cluster-0.elasticsearch"
                },
                {
                  "name"  = "cluster.initial_master_nodes"
                  "value" = "es-cluster-0"
                },
                {
                  "name"  = "ES_JAVA_OPTS"
                  "value" = "-Xms512m -Xmx512m"
                },
              ]
              "image" = "docker.elastic.co/elasticsearch/elasticsearch:7.2.0"
              "name"  = "elasticsearch"
              "ports" = [
                {
                  "containerPort" = 9200
                  "name"          = "rest"
                  "protocol"      = "TCP"
                },
                {
                  "containerPort" = 9300
                  "name"          = "inter-node"
                  "protocol"      = "TCP"
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
              "volumeMounts" = [
                {
                  "mountPath" = "/usr/share/elasticsearch/data"
                  "name"      = "data"
                },
              ]
            },
          ]
          "initContainers" = [
            {
              "command" = [
                "sh",
                "-c",
                "chown -R 1000:1000 /usr/share/elasticsearch/data",
              ]
              "image" = "busybox"
              "name"  = "fix-permissions"
              "securityContext" = {
                "privileged" = true
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/usr/share/elasticsearch/data"
                  "name"      = "data"
                },
              ]
            },
            {
              "command" = [
                "sysctl",
                "-w",
                "vm.max_map_count=262144",
              ]
              "image" = "busybox"
              "name"  = "increase-vm-max-map"
              "securityContext" = {
                "privileged" = true
              }
            },
            {
              "command" = [
                "sh",
                "-c",
                "ulimit -n 65536",
              ]
              "image" = "busybox"
              "name"  = "increase-fd-ulimit"
              "securityContext" = {
                "privileged" = true
              }
            },
          ]
        }
      }
      "volumeClaimTemplates" = [
        {
          "metadata" = {
            "labels" = {
              "app" = "elasticsearch"
            }
            "name" = "data"
          }
          "spec" = {
            "accessModes" = [
              "ReadWriteOnce",
            ]
            "resources" = {
              "requests" = {
                "storage" = "5Gi"
              }
            }
            "storageClassName" = "standard"
          }
        },
      ]
    }
  }
}
