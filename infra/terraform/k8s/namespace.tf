resource "kubernetes_namespace_v1" "velib" {
  metadata {
    name = "velib-insights"
  }
}
