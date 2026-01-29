resource "kubernetes_ingress_v1" "velib_ingress" {
  metadata {
    name = "velib-ingress"
    namespace = kubernetes_namespace_v1.velib.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"               = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }

  spec {
    rule {
      http {

        # BACKEND API
        path {
          path      = "/api(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service_v1.backend_svc.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }

        # FRONTEND
        path {
          path      = "/"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service_v1.frontend_svc.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}
