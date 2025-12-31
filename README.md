# Kubernetes Platform

A comprehensive Terraform-based infrastructure-as-code solution for deploying a production-ready Azure Kubernetes Service (AKS) platform with essential services and tooling.

## Overview

This repository provisions a complete Kubernetes platform on Azure, including:

- **Azure Kubernetes Service (AKS)** - Managed Kubernetes cluster with user-assigned identities
- **Azure Container Registry (ACR)** - Private container image registry with AKS integration
- **Virtual Network** - Dedicated VNet and subnet for AKS nodes
- **NGINX Ingress Controller** - HTTP/HTTPS routing and load balancing
- **Cert-Manager** - Automated TLS certificate management with Let's Encrypt
- **Argo CD** - GitOps continuous delivery for Kubernetes

## Architecture

The infrastructure is designed with security and scalability in mind:

- **Managed Identities**: AKS uses separate user-assigned managed identities for the control plane and kubelet, following Azure best practices
- **Network Isolation**: Dedicated VNet (10.0.0.0/16) with AKS subnet (10.0.1.0/24)
- **RBAC**: Azure AD integration for role-based access control
- **Auto-scaling**: Configured node pool with min/max scaling capabilities
- **GitOps**: Argo CD for declarative application deployments

## Prerequisites

Before deploying this infrastructure, ensure you have:

1. **Azure CLI** installed and authenticated
   ```bash
   az login
   ```

2. **Terraform** >= 1.9.0
   ```bash
   terraform version
   ```

3. **kubectl** for Kubernetes cluster access
   ```bash
   kubectl version --client
   ```

4. **Azure Subscription** with appropriate permissions to create resources

5. **Azure Storage Account** for Terraform state backend (optional but recommended)

## Repository Structure

```
kubernetes-platform/
├── terraform/
│   ├── acr.tf                    # Azure Container Registry
│   ├── aks-cluster.tf            # AKS cluster and managed identities
│   ├── argocd.tf                 # Argo CD Helm deployment
│   ├── cert-manager.tf           # Cert-manager Helm deployment
│   ├── data.tf                   # Data sources
│   ├── modules.tf                # Terraform module configurations
│   ├── networking.tf             # VNet and subnets
│   ├── nginx-ingress.tf          # NGINX Ingress Controller
│   ├── variables.tf              # Variable definitions
│   ├── versions.tf               # Provider configurations
│   ├── environment/
│   │   ├── default.tfvars        # Default values
│   │   ├── dev/
│   │   │   └── variables.tfvars  # Development environment
│   │   ├── uat/
│   │   │   └── variables.tfvars  # UAT environment
│   │   └── prod/
│   │       └── variables.tfvars  # Production environment
│   └── k8s/
│       └── cert-manager-issuer.yaml  # Let's Encrypt ClusterIssuer
└── README.md
```

## Configuration

### Environment-Specific Variables

Each environment (dev, uat, prod) has its own tfvars file in `terraform/environment/`. Key variables include:

- `app_name` - Application/project name (max 20 chars, lowercase alphanumeric)
- `environment` - Environment tag (dev, uat, stg, sys, poc, prod)
- `azrm_subscription_id` - Azure subscription ID
- `azrm_tenant_id` - Azure AD tenant ID
- `azrm_resource_location` - Azure region (e.g., eastus, westeurope)
- `domain_name` - Custom domain for ingress

### Backend Configuration

Configure Terraform backend for remote state storage in `versions.tf`:

```hcl
backend "azurerm" {
  resource_group_name  = "terraform-state-rg"
  storage_account_name = "tfstate<unique>"
  container_name       = "tfstate"
  key                  = "kubernetes-platform.tfstate"
}
```

## Deployment

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Select Environment and Workspace

```bash
# For development
terraform workspace select dev || terraform workspace new dev
```

### 3. Plan Deployment

```bash
terraform plan -var-file="environment/dev/variables.tfvars"
```

### 4. Apply Infrastructure

```bash
terraform apply -var-file="environment/dev/variables.tfvars"
```

### 5. Configure kubectl

```bash
az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
```

## Post-Deployment

### Access Argo CD

1. **Get the LoadBalancer IP:**
   ```bash
   kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
   ```

2. **Retrieve initial admin password:**
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
   ```

3. **Login to Argo CD:**
   - Username: `admin`
   - Password: (from step 2)

### Configure Cert-Manager ClusterIssuer

Apply the Let's Encrypt ClusterIssuer:

```bash
kubectl apply -f terraform/k8s/cert-manager-issuer.yaml
```

Update the email address in the issuer configuration before applying.

### Verify Deployments

```bash
# Check all pods
kubectl get pods -A

# Check NGINX Ingress
kubectl get svc -n ingress-nginx

# Check Cert-Manager
kubectl get pods -n cert-manager

# Check Argo CD
kubectl get pods -n argocd
```

## Resource Naming

Resources are named using the Azure Naming module which follows Azure naming conventions:

- AKS Cluster: `aks-<app_name>-<environment>-<region>`
- ACR: `acr<app_name><environment><region>` (alphanumeric only)
- VNet: `vnet-<app_name>-<environment>-<region>`

## Security Features

- **Azure AD RBAC**: Integrated authentication and authorization
- **Managed Identities**: No service principal credentials to manage
- **Network Policies**: Azure CNI network plugin
- **Private ACR**: Only accessible by AKS with AcrPull role assignment
- **TLS Certificates**: Automated with cert-manager and Let's Encrypt
- **Auto-upgrade**: Scheduled maintenance windows for security patches

## Scaling

The default node pool is configured with:
- VM Size: Standard_DS2_v2
- Initial nodes: 3
- Min nodes: 3
- Max nodes: 3
- Auto-scaling: Enabled

Adjust in `aks-cluster.tf` based on workload requirements.

## Maintenance

### Upgrade Windows

AKS auto-upgrade is configured for:
- Frequency: Weekly
- Day: Sunday
- Time: 00:00 UTC
- Duration: 4 hours

Modify in `aks-cluster.tf` to fit your maintenance schedule.

## Troubleshooting

### AKS Cluster Issues

```bash
# View cluster details
az aks show --resource-group <rg-name> --name <aks-name>

# Check node status
kubectl get nodes

# View pod logs
kubectl logs <pod-name> -n <namespace>
```

### Helm Release Issues

```bash
# List Helm releases
helm list -A

# Check release status
helm status <release-name> -n <namespace>

# View Helm values
helm get values <release-name> -n <namespace>
```

### Identity Permission Issues

Verify role assignments:

```bash
az role assignment list --assignee <managed-identity-principal-id>
```

## Cost Optimization

- Basic ACR SKU for development (upgrade to Premium for production)
- Right-size VM SKUs based on workload
- Use spot instances for non-critical workloads
- Enable cluster autoscaler
- Consider Azure Reserved Instances for production

## Contributing

1. Create a feature branch
2. Make changes and test
3. Submit a pull request
4. Ensure Terraform fmt and validate pass

## Cleanup

To destroy all resources:

```bash
terraform destroy -var-file="environment/dev/variables.tfvars"
```

⚠️ **Warning**: This will delete all resources including the AKS cluster and ACR with all images.

## Support

For issues or questions:
- Review Terraform plan output carefully
- Check Azure Activity Log for resource creation failures
- Consult AKS troubleshooting documentation
- Review provider documentation for module versions

## License

MIT License - See LICENSE file for details
