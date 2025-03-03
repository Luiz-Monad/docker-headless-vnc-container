#based on https://github.com/virtual-kubelet/azure-aci/blob/master/README.md

Install-Module -Name Az.Aks -Repository PSGallery
Install-Module -Name Az.Compute -Repository PSGallery
Install-Module -Name Az.Resources -Repository PSGallery

Import-Module Az.Aks
Import-Module Az.Compute
Import-Module Az.Resources

Login-AzAccount
$ssh = (Get-Content '~/.ssh/id_rsa.pub')

$resource_group = 'docker-swarm'
$cluster_location = 'westcentralus'
$cluster_name = 'swarm'
$dns_name = 'cluster'
$vnet_name = 'cluster-vnet'
$vnet_address = '10.0.0.0/8'
$vnet_subnet_k8s_name = 'default'
$vnet_subnet_k8s_address = '10.240.0.0/16'
$vnet_subnet_aci_name = 'aci'
$vnet_subnet_aci_address = '10.241.0.0/16'
$cluster_service_cidr = '10.0.0.0/16'
$cluster_dns_ip='10.0.0.10'
$cluster_docker_cidr = '172.17.0.1/16'
$service_principal = 'virtual-kubelet-sp'

# =======================================================================================

New-AzResourceGroup `
    -Name $resource_group `
    -Location $cluster_location

# =======================================================================================

$cluster_vnet = New-AzVirtualNetworkSubnetConfig `
    -Name $vnet_subnet_k8s_name `
    -AddressPrefix $vnet_subnet_k8s_address

$aci_vnet = New-AzVirtualNetworkSubnetConfig `
    -Name $vnet_subnet_aci_name `
    -AddressPrefix $vnet_subnet_aci_address

$vnet = New-AzVirtualNetwork `
    -ResourceGroupName $resource_group `
    -Location $cluster_location `
    -Name $vnet_name `
    -AddressPrefix $vnet_address `
    -Subnet $cluster_vnet, $aci_vnet

$sp = New-AzADServicePrincipal -DisplayName $service_principal
$pw = ConvertTo-SecureString -AsPlainText $sp.PasswordCredentials.SecretText
$cred = [System.Management.Automation.PSCredential]::new($sp.AppId, $pw)

New-AzRoleAssignment `
    -RoleDefinitionName 'Network Contributor' `
    -Scope ($vnet.Id) `
    -ApplicationId ($sp.AppId)

# =======================================================================================

$cluster_vnet = Get-AzVirtualnetwork | 
    Get-AzVirtualNetworkSubnetConfig `
        -Name $vnet_subnet_k8s_name

New-AzAksCluster `
    -ResourceGroupName $resource_group `
    -Name $cluster_name `
    -SshKeyValue $ssh `
    -KubernetesVersion '1.22.6' `
    -DnsNamePrefix $dns_name `
    -NetworkPlugin azure `
    -LoadBalancerSku standard `
    -ServiceCidr $cluster_service_cidr `
    -DnsServiceIP $cluster_dns_ip `
    -DockerBridgeCidr $cluster_docker_cidr `
    -NodeName 'agentpool' `
    -NodeOsDiskSize 30 `
    -NodeCount 1 `
    -NodeMaxPodCount 250 `
    -NodePoolMode System `
    -NodeVmSetType VirtualMachineScaleSets `
    -NodeVmSize 'Standard_A2_v2' `
    -NodeVnetSubnetID $cluster_vnet.Id `
    -SubnetName $vnet_subnet_k8s_name `
    -EnableRbac:$false `
    -ServicePrincipalIdAndSecret $cred `
    -Verbose

$cluster = Get-AzAksCluster `
    -ResourceGroupName $resource_group `
    -Name $cluster_name 

# =======================================================================================

# $cluster | Enable-AzAksAddOn `
#     -SubnetName $vnet_subnet_aci_name `
#     -Name VirtualNode

# choco install kubernetes-helm
# Install-AzAksKubectl -Destination (Get-Item .)
$cluster | Import-AzAksCredential -Force

$release='virtual-kubelet'
$vk_release='virtual-kubelet-latest'
$chart="https://github.com/virtual-kubelet/azure-aci/raw/master/charts/$vk_release.tgz"

# helm uninstall "$release" --namespace='kube-system'
helm install "$release" "$chart" `
    --set provider=azure `
    --set rbac.install=true `
    --set providers.azure.targetAKS=true `
    --set providers.azure.managedIdentityID="$($sp.Id)" `
    --set providers.azure.vnet.enabled=true `
    --set providers.azure.vnet.vnetResourceGroup="$resource_group" `
    --set providers.azure.vnet.vnetName="$vnet_name" `
    --set providers.azure.vnet.subnetName="$vnet_subnet_aci_name" `
    --set providers.azure.vnet.subnetCidr="$vnet_subnet_aci_address" `
    --set providers.azure.vnet.clusterCidr="$vnet_subnet_k8s_address" `
    --set providers.azure.vnet.kubeDnsIp="$cluster_dns_ip" `
    --set providers.azure.masterUri="https://$($cluster.Fqdn)" `
    --set nodeName='aci-connector' `
    --namespace='kube-system'

# =======================================================================================

$cluster | Import-AzAksCredential -ConfigPath (Join-Path (Get-Item .) 'kube-config') -Force
# kubectl delete configmap server
kubectl create configmap server --from-file 'kube-config'
Remove-Item 'kube-config'

# kubectl delete secret server
kubectl create secret generic server --from-literal=vncpass=$env:vncpass

# kubectl delete secret client
kubectl create secret generic client --from-literal=vncpass=$env:vncpass
