$resourceGroupName = "rg-eshop"
$ACR = "eshopacrnils"

# Create an Azure Kubernetes Service
az aks create -n aks-eshop -g $resourceGroupName `
    --network-plugin Azure `
    --enable-managed-identity `
    --enable-addon ingress-appgw `
    --appgw-name aks-appgw `
    --appgw-subnet-cidr "10.225.0.0/16" `
    --generate-ssh-keys `
    --attach-acr $ACR

# Get the kubeconfig to log into the cluster
az aks get-credentials --resource-group $resourceGroupName --name aks-eshop



#### Use Let's Encrypt to create a SSL certificate for the ingress controller

# Install the CustomResourceDefinition resources separately
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.crds.yaml

# Create the namespace for cert-manager
kubectl create namespace cert-manager

# Label the cert-manager namespace to disable resource validation
kubectl label namespace cert-manager cert-manager.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
# Helm v3+
helm install `
  cert-manager jetstack/cert-manager `
  --namespace cert-manager `
  --version v1.14.4
  # --set installCRDs=true

# To automatically install and manage the CRDs as part of your Helm release,
# you must add the --set installCRDs=true flag to your Helm installation command.

$yaml = @'
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt uses this to contact you about expiring
    # certificates, and issues related to your account.
    email: ngruson@hotmail.com
    # ACME server URL for Let’s Encrypt’s staging environment.
    # The staging environment won't issue trusted certificates but is
    # used to ensure that the verification process is working properly
    # before moving to production
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource used to store the account's private key.
      name: letsencrypt-secret
    # Enable the HTTP-01 challenge provider
    # you prove ownership of a domain by ensuring that a particular
    # file is present at the domain
    solvers:
    - http01:
        ingress:
          class: azure/application-gateway
'@

$yaml |kubectl apply -f -

# Delete the cluster
# az aks delete --resource-group $resourceGroupName --name aks-eshop --yes