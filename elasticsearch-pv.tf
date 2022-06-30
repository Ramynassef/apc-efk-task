resource "kubernetes_manifest" "persistentvolume_data" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "PersistentVolume"
    "metadata" = {
      "labels" = {
        "type" = "local"
      }
      "name" = "data"
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "capacity" = {
        "storage" = "5Gi"
      }
      "hostPath" = {
        "path" = "/mnt/data"
      }
      "storageClassName" = "standard"
    }
  }
}
