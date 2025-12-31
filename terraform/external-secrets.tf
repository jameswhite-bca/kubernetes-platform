# kubernetes-platform/terraform/external-secrets.tf

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets-system"
  create_namespace = true
  version          = "0.9.11"

  set {
    name  = "installCRDs"
    value = "true"
  }

  # Wait for ESO to be ready
  wait          = true
  wait_for_jobs = true
  timeout       = 600
}