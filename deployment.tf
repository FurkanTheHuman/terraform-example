resource "kubernetes_namespace" "kube" {
  metadata {
    name = "project"
  }
}

resource "kubernetes_deployment" "kube" {
  wait_for_rollout = false
  metadata {
    name = "example-project-backend"
    namespace = "project"
    labels = {
      test = "backend"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        test = "backend"
      }
    }

    template {
      metadata {
        labels = {
            test = "backend"
        }
      }

      spec {
        container {
          image = "nginx:1.21.6"
          name  = "backend"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

        
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "frontend" {
  wait_for_rollout = false
  metadata {
    name = "example-project-frontend"
    namespace = "project"
    labels = {
      test = "frontend"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        test = "frontend"
      }
    }

    template {
      metadata {
        labels = {
            test = "frontend"
        }
      }

      spec {
        container {
          image = "nginx:1.21.6"
          name  = "frontend"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

        
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}

resource "kubernetes_service" "example" {
  metadata {
    name = "project-frontend"
    namespace = "project"
  }
  spec {
    selector = {
      test = kubernetes_deployment.frontend.metadata[0].labels.test
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "project_ingress" {
    wait_for_load_balancer = true
  metadata {
    name = "project-frontend"
    namespace = "project"
  }

  spec {
    ingress_class_name = "nginx"
    default_backend {
      service {
        name = "project-frontend"
        port {
          number = 80
        }
      }
    }
    
    rule {
      host = "project.example.com"
      http {
        path {
          backend {
            service {
              name = "project-frontend"
              port {
                number = 80
              }
            }
          }

          path = "/"
        }

      }
    }

  }
}
