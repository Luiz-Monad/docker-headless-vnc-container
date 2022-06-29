
Install-Module -Name Az.Aks -Repository PSGallery
Install-Module -Name Az.Compute -Repository PSGalleryx

Import-Module Az.Aks
Import-Module Az.Compute

Login-AzAccount

New-AzResourceGroup `
    -Name $env:aks_resource_group `
    -Location $env:aks_location

New-AzResourceGroupDeployment `
    -ResourceGroupName $env:aks_resource_group `
    -TemplateFile cluster.json `
    -TemplateParameterFile cluster.parameters.json `
    -Debug

Install-AzAksKubectl -Destination (Get-Item .)
Get-AzAksCluster | Import-AzAksCredential -ConfigPath (Join-Path (Get-Item .) 'kube-config') -Force

kubectl delete configmap server
kubectl create configmap server --from-file 'kube-config'

kubectl delete secret server
kubectl create secret generic server --from-literal=vncpass=$env:vncpass

kubectl delete secret client
kubectl create secret generic client --from-literal=vncpass=$env:vncpass
