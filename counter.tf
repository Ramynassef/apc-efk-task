resource "kubernetes_manifest" "pod_counter" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Pod"
    "metadata" = {
      "name"      = "counter"
      "namespace" = "kube-logging"
    }
    "spec" = {
      "containers" = [
        {
          "args" = [
            "/bin/sh",
            "-c",
            "i=0; while true; do echo \"$i: $(date)\"; i=$((i+1)); sleep 1; done",
          ]
          "image" = "busybox"
          "name"  = "count"
        },
      ]
    }
  }
}
