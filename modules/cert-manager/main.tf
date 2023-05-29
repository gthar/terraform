terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  namespace        = "cert-manager"
  create_namespace = true
  version          = var.cert_manager_version
  set {
    name  = "installCRDs"
    value = true
  }
}

resource "helm_release" "cert-manager-webhook-hetzner" {
  name       = "cert-manager-webhook-hetzner"
  chart      = "cert-manager-webhook-hetzner"
  repository = "https://vadimkim.github.io/cert-manager-webhook-hetzner"
  namespace  = helm_release.cert-manager.namespace
  set {
    name  = "groupName"
    value = var.group_name
  }
}

resource "kubernetes_secret" "hetzner-token" {
  metadata {
    name      = "hetzner-token"
    namespace = helm_release.cert-manager.namespace
  }
  type = "Opaque"
  data = {
    api-key = var.hetzner_token
  }
}

#resource "kubernetes_manifest" "clusterissuer_letsencrypt_staging" {
#  manifest = {
#    apiVersion = "cert-manager.io/v1"
#    kind       = "ClusterIssuer"
#    metadata = {
#      name = "letsencrypt-staging"
#    }
#    spec = {
#      acme = {
#        email = var.email
#        privateKeySecretRef = {
#          name = "letsencrypt-staging-account-key"
#        }
#        server = var.letsencrypt_servers.staging
#        solvers = [
#          {
#            dns01 = {
#              webhook = {
#                config = {
#                  apiUrl     = var.hetzner_dns_api
#                  secretName = kubernetes_secret.hetzner-token.metadata[0].name
#                  zoneName   = var.zone_name
#                }
#                groupName  = var.group_name
#                solverName = "hetzner"
#              }
#            }
#          }
#        ]
#      }
#    }
#  }
#}

resource "kubernetes_manifest" "clusterissuer_letsencrypt" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt"
    }
    spec = {
      acme = {
        email = var.email
        privateKeySecretRef = {
          name = "letsencrypt-account-key"
        }
        server = var.letsencrypt_servers.prod
        solvers = [
          {
            dns01 = {
              webhook = {
                config = {
                  apiUrl     = var.hetzner_dns_api
                  secretName = kubernetes_secret.hetzner-token.metadata[0].name
                  zoneName   = var.zone_name
                }
                groupName  = var.group_name
                solverName = "hetzner"
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "certificate_cert_manager" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = format("%s-cert", replace(var.dns_common_name, ".", "-"))
      namespace = helm_release.cert-manager.namespace
    }
    spec = {
      commonName = var.dns_common_name
      dnsNames   = var.dns_names
      issuerRef = {
        kind = "ClusterIssuer"
        name = kubernetes_manifest.clusterissuer_letsencrypt.manifest.metadata.name
      }
      secretName = format("%s-cert", replace(var.dns_common_name, ".", "-"))
    }
  }
}
