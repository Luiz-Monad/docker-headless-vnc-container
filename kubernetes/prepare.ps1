
Install-Module -Name Az.Aks -Repository PSGallery
Import-Module -Name Az.Aks

Install-AzAksKubectl -Destination (Get-Item .)
Get-AzAksCluster | Import-AzAksCredential -ConfigPath (Join-Path (Get-Item .) 'kube-config') -Force

kubectl delete configmap server
kubectl create configmap server --from-file 'kube-config'

kubectl delete secret server
kubectl create secret generic server --from-literal=vncpass=$env:vncpass

kubectl delete secret client
kubectl create secret generic client --from-literal=vncpass=$env:vncpass
