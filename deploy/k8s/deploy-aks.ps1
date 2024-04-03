# Ingress DNS
$ingress = "https://dev.myeshopdemo.com"

# RabbitMQ
kubectl create -f .\yaml\rabbitmq.yaml
# kubectl apply -f .\yaml\rabbitmq.yaml

# Redis
kubectl create -f .\yaml\redis.yaml

# Postgres

$postgresPassword = [guid]::NewGuid().ToString("N")
echo $postgresPassword

kubectl create secret generic secret-postgres --from-literal=POSTGRES_PASSWORD=$postgresPassword
# kubectl delete secret secret-postgres

kubectl apply -f .\yaml\postgres.yaml
# kubectl delete -f .\yaml\postgres.yaml

# Catalog API

$connectionString = "Host=postgres;Database=CatalogDB;Username=postgres;Password=$postgresPassword"
kubectl create secret generic secret-catalogapi --from-literal=CONNECTIONSTRING__CATALOGDB=$connectionString
# kubectl delete secret secret-catalogapi

kubectl apply -f .\yaml\catalogapi.yaml
# kubectl delete -f .\yaml\catalogapi.yaml

# Identity API

$connectionString = "Host=postgres;Database=IdentityDB;Username=postgres;Password=$postgresPassword"
kubectl create secret generic secret-identityapi --from-literal=CONNECTIONSTRING__IDENTITYDB=$connectionString
kubectl create configmap configmap-identityapi `
    --from-literal=WebAppClient=$ingress `
    --from-literal=Origin=$ingress/identityapi
    

kubectl apply -f .\yaml\identityapi.yaml

# kubectl delete -f .\yaml\identityapi.yaml
# kubectl delete secret secret-identityapi
# kubectl delete cm configmap-identityapi

kubectl describe cm configmap-identityapi

# Basket API

kubectl create configmap configmap-basketapi `
    --from-literal=IdentityUrl=$ingress/identityapi

kubectl create -f .\yaml\basketapi.yaml
# kubectl delete -f .\yaml\basketapi.yaml

# Ordering API

$connectionString = "Host=postgres;Database=OrderingDB;Username=postgres;Password=$postgresPassword"
kubectl create secret generic secret-orderingapi --from-literal=CONNECTIONSTRING__ORDERINGDB=$connectionString

kubectl apply -f .\yaml\orderingapi.yaml
# kubectl delete -f .\yaml\orderingapi.yaml

# Order Processor

$connectionString = "Host=postgres;Database=OrderingDB;Username=postgres;Password=$postgresPassword"
kubectl create secret generic secret-orderprocessor --from-literal=CONNECTIONSTRING__ORDERINGDB=$connectionString

kubectl apply -f .\yaml\orderprocessor.yaml
# kubectl delete -f .\yaml\orderprocessor.yaml

# Payment Processor

kubectl apply -f .\yaml\paymentprocessor.yaml
# kubectl delete -f .\yaml\paymentprocessor.yaml

# Web App

#$identityApi = $(kubectl get svc identityapi -o jsonpath='{ .status.loadBalancer.ingress[].ip }')
#echo $identityApi

kubectl create configmap configmap-webapp `
    --from-literal=IdentityUrl=$ingress/identityapi `
    --from-literal=CallBackUrl=$ingress

# kubectl edit configmap configmap-webapp

kubectl apply -f .\yaml\webapp.yaml

# kubectl delete -f .\yaml\webapp.yaml
# kubectl delete configmap configmap-webapp
# kubectl describe configmap configmap-webapp

# Update configmaps
$webapp = $(kubectl get svc webapp-service -o jsonpath='{ .status.loadBalancer.ingress[].ip }')
echo $webapp

#$data = "{`"data`":{`"CallBackUrl`":`"$ingress`"}}"
#kubectl patch configmap configmap-webapp --type merge -p $data

#$data = "{`"data`":{`"WebAppClient`":`"http://$webapp`"}}"
#kubectl patch configmap configmap-identityapi --type merge -p $data

# Update the authority if necessary
#$data = "{`"data`":{`"IdentityUrl`":`"http://$identityApi`"}}"
#kubectl patch configmap configmap-webapp --type merge -p $data

kubectl describe cm configmap-webapp
kubectl describe cm configmap-identityapi

kubectl delete cm configmap-webapp

# Ingress
kubectl apply -f .\yaml\ingress.yaml
$ingressIp = $(kubectl get ingress eshop-ingress -o jsonpath='{ .status.loadBalancer.ingress[].ip }')
echo $ingressIp

# kubectl get ingress eshop-ingress
kubectl delete -f .\yaml\ingress.yaml
kubectl describe ingress eshop-ingress