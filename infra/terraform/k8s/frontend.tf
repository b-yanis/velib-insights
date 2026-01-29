resource "kubernetes_deployment_v1" "frontend" {
  metadata {
    name      = "velib-frontend"
    namespace = kubernetes_namespace_v1.velib.metadata[0].name
    labels = { app = "velib-frontend" }
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "velib-frontend" }
    }
    template {
      metadata { labels = { app = "velib-frontend" } }
      spec {
        container {
          name  = "velib-frontend"
          image = "yanisble/velib-insights-client:latest"
          image_pull_policy = "Always"
          port { container_port = 3000 }
        }

      }
    }
  }

}

resource "kubernetes_service_v1" "frontend_svc" {
  metadata {
    name      = "frontend-service"
    namespace = kubernetes_namespace_v1.velib.metadata[0].name
  }

  spec {
    selector = { app = "velib-frontend" }
    port {
      port        = 3000
      target_port = 3000
    }
    type = "ClusterIP"
  }
}
