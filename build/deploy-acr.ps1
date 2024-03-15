# Create a resource group 
$resourceGroupName = "rg-eshop"
az group create --name $resourceGroupName --location westeurope

# Create an Azure Container Registry
$ACR = "eshopacrnils"
az acr create --resource-group $resourceGroupName --name $ACR --sku Basic