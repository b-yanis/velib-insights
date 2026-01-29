resource "kubernetes_deployment_v1" "backend" {
  metadata {
    name      = "velib-backend"
    namespace = kubernetes_namespace_v1.velib.metadata[0].name
    labels = { app = "velib-backend" }
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "velib-backend" }
    }
    template {
      metadata { labels = { app = "velib-backend" } }
      spec {
        container {
          name  = "velib-backend"
          image = "yanisble/velib-insights-server"
          image_pull_policy = "Always"
          port { container_port = 5000 }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "backend_svc" {
  metadata {
    name      = "backend-service"
    namespace = kubernetes_namespace_v1.velib.metadata[0].name
  }

  spec {
    selector = { app = "velib-backend" }
    port {
      port        = 80
      target_port = 5000
    }
    type = "ClusterIP"
  }
}
