terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}

# terraform import module.minio.kubernetes_namespace.minio_namespace minio
resource "kubernetes_namespace" "minio_namespace" {
  metadata {
    name = "minio"
  }
}

# terraform import module.minio.kubernetes_persistent_volume.minio-pv minio-pv
resource "kubernetes_persistent_volume" "minio-pv" {
  metadata {
    name = "minio-pv"
  }
  spec {
    capacity           = { storage = var.minio_storage_capacity }
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "local"
    persistent_volume_source {
      host_path { path = var.minio_host_path }
    }
  }
}

# terraform import module.minio.kubernetes_persistent_volume_claim.minio-pvc minio/minio-pvc
resource "kubernetes_persistent_volume_claim" "minio-pvc" {
  metadata {
    name      = "minio-pvc"
    namespace = kubernetes_namespace.minio_namespace.metadata[0].name
  }
  spec {
    storage_class_name = "local"
    volume_name        = kubernetes_persistent_volume.minio-pv.metadata[0].name
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = { storage = var.minio_storage_capacity }
    }
  }
}

# terraform import module.minio.kubernetes_secret.minio-secret minio/minio-secret
resource "kubernetes_secret" "minio-secret" {
  metadata {
    name      = "minio-secret"
    namespace = kubernetes_namespace.minio_namespace.metadata[0].name
  }
  type                           = "Opaque"
  wait_for_service_account_token = false
  data = {
    root_user     = var.minio_root_user
    root_password = var.minio_root_password
  }
}

# terraform import module.minio.kubernetes_deployment.minio-deployment minio/minio-deployment
resource "kubernetes_deployment" "minio-deployment" {
  metadata {
    name      = "minio-deployment"
    namespace = kubernetes_namespace.minio_namespace.metadata[0].name
  }
  spec {
    selector {
      match_labels = { app = "minio" }
    }
    template {
      metadata {
        labels = { app = "minio" }
      }
      spec {
        container {
          name  = "minio"
          image = var.minio_image
          args = [
            "server",
            "--console-address",
            format(":%s", var.minio_console_port),
            "/storage"
          ]
          env {
            name = "MINIO_ROOT_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio-secret.metadata[0].name
                key  = "root_user"
              }
            }
          }
          env {
            name = "MINIO_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio-secret.metadata[0].name
                key  = "root_password"
              }
            }
          }
          env {
            name  = "MINIO_BROWSER_REDIRECT_URL"
            value = format("https://%s", var.minio_console_url)
          }
          port {
            container_port = var.minio_port
            host_port      = var.minio_port
          }
          port {
            container_port = var.minio_console_port
            host_port      = var.minio_console_port
          }
          volume_mount {
            name       = "storage"
            mount_path = "/storage"
          }
        }
        volume {
          name = "storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.minio-pvc.metadata[0].name
          }
        }
        automount_service_account_token = false
        enable_service_links            = false
      }
    }
  }
  wait_for_rollout = false
}

# terraform import module.minio.kubernetes_service.minio-svc minio/minio-svc
resource "kubernetes_service" "minio-svc" {
  metadata {
    name      = "minio-svc"
    namespace = kubernetes_namespace.minio_namespace.metadata[0].name
    labels    = { service = "minio" }
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = kubernetes_deployment.minio-deployment.spec[0].template[0].metadata[0].labels.app
    }
    port {
      name     = "minio"
      port     = var.minio_port
      protocol = "TCP"
    }
    port {
      name     = "minio-console"
      port     = var.minio_console_port
      protocol = "TCP"
    }
  }
  wait_for_load_balancer = false
}

# terraform import module.minio.kubernetes_ingress_v1.minio-ingress minio/minio-ingress
resource "kubernetes_ingress_v1" "minio-ingress" {
  metadata {
    name      = "minio-ingress"
    namespace = kubernetes_namespace.minio_namespace.metadata[0].name
  }
  spec {
    rule {
      host = var.minio_url
      http {
        path {
          path_type = "Prefix"
          path      = "/"
          backend {
            service {
              name = kubernetes_service.minio-svc.metadata[0].name
              port { number = var.minio_port }
            }
          }
        }
      }
    }
    rule {
      host = var.minio_console_url
      http {
        path {
          path_type = "Prefix"
          path      = "/"
          backend {
            service {
              name = kubernetes_service.minio-svc.metadata[0].name
              port { number = var.minio_console_port }
            }
          }
        }
      }
    }
  }
}
