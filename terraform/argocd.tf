# Create namespace for Argo CD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [module.aks_cluster]
}

# Deploy Argo CD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.7.11" # Check for latest version at https://github.com/argoproj/argo-helm
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    yamlencode({
      global = {
        domain = "argocd.example.com" # Update with your domain
      }

      configs = {
        params = {
          "server.insecure" = true # Set to false if using TLS
        }
      }

      server = {
        service = {
          type = "LoadBalancer" # Change to "ClusterIP" if using ingress
        }
        
        # Uncomment if using nginx-ingress
        # ingress = {
        #   enabled = true
        #   ingressClassName = "nginx"
        #   annotations = {
        #     "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
        #   }
        #   hosts = ["argocd.example.com"]
        #   tls = [{
        #     secretName = "argocd-server-tls"
        #     hosts = ["argocd.example.com"]
        #   }]
        # }
      }

      # Enable HA mode (optional)
      redis-ha = {
        enabled = false # Set to true for production HA setup
      }

      controller = {
        replicas = 1 # Increase for HA
      }

      repoServer = {
        replicas = 1 # Increase for HA
      }

      applicationSet = {
        replicas = 1 # Increase for HA
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# After deployment, retrieve Argo CD credentials:
# - Initial admin password:
#   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
#
# - Server URL/IP:
#   kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
