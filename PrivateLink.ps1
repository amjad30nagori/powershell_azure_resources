#--------------Storage Account Information---------#

$storageaccount = "csg100320014a90a68c"
$storageaccountrg = "cloud-shell-storage-centralindia"
$container = "az-resource-settings"

#--------------Storage Account---------------------#

$sa = Get-AzStorageAccount -Name $storageaccount -ResourceGroupName $storageaccountrg

#---------------All Key Vaults--------------------#

$allprivatelink = Get-AzPrivateLinkService

#------------------------------------privls Table Creation----------------------------------#

Add-Type -AssemblyName 'System.Web'
$privlsTable = New-Object System.Data.DataTable
$privlsTable.Columns.Add("Name","string") | Out-Null
$privlsTable.Columns.Add("ResourceGroup","string") | Out-Null
$privlsTable.Columns.Add("Location","string") | Out-Null
$privlsTable.Columns.Add("Type","string") | Out-Null
$privlsTable.Columns.Add("Alias","string") | Out-Null
$privlsTable.Columns.Add("EnableProxyProtocol","string") | Out-Null
$privlsTable.Columns.Add("VirtualNetwork","string") | Out-Null
$privlsTable.Columns.Add("Subnet","string") | Out-Null
$privlsTable.Columns.Add("LoadBalancer","string") | Out-Null
$privlsTable.Columns.Add("LBFrontEnd","string") | Out-Null
$privlsTable.Columns.Add("PrivateEndpoint","string") | Out-Null
$privlsTable.Columns.Add("PrivateLinkServiceConnectionState","string") | Out-Null
$privlsTable.Columns.Add("IPAddress","string") | Out-Null

#------------------------------------------------------------------------------------#

foreach($privls in $allprivatelink)
{

    $Name=$privls.Name
    $ResourceGroup=$privls.ResourceGroupName
    $Location=$privls.Location
    $Type=$privls.Type
    $Alias=$privls.Alias
    $EnableProxyProtocol=$privls.EnableProxyProtocol
    $VirtualNetwork=$privls.IpConfigurations.Subnet.Id.Split("/")[8]
    $Subnet=$privls.IpConfigurations.Subnet.Id.Split("/")[10]
    $LoadBalancer = $privls.LoadBalancerFrontendIpConfigurations.Id.Split("/")[8]
    $LBFrontEnd=$privls.LoadBalancerFrontendIpConfigurations.Id.Split("/")[10]
    $PrivateEndpoint=$privls.PrivateEndpointConnections.PrivateEndpoint.Id.Split("/")[8]
    $PrivateLinkServiceConnectionState=$privls.PrivateEndpointConnections.PrivateLinkServiceConnectionState.Status
    $IPAddress=(Get-AzNetworkInterface -ResourceId $privls.NetworkInterfaces.Id).IpConfigurations.PrivateIpAddress

    $privlsrow = $privlsTable.NewRow()
    $privlsrow.Name=$Name
    $privlsrow.ResourceGroup= $ResourceGroup
    $privlsrow.Location=$Location
    $privlsrow.Type=$Type
    $privlsrow.Alias=$Alias
    $privlsrow.EnableProxyProtocol=$EnableProxyProtocol
    $privlsrow.VirtualNetwork=$VirtualNetwork
    $privlsrow.Subnet=$Subnet
    $privlsrow.LoadBalancer=$LoadBalancer
    $privlsrow.LBFrontEnd=$LBFrontEnd
    $privlsrow.PrivateEndpoint=$PrivateEndpoint
    $privlsrow.PrivateLinkServiceConnectionState=$PrivateLinkServiceConnectionState
    $privlsrow.IPAddress=$IPAddress
    $privlsTable.Rows.Add($privlsrow) | Out-Null
}

#--------------------------------------Output-----------------------------------------#

$privlsTable | Export-Csv PrivateLinkSettings.csv -NoTypeInformation -Force
Set-AzStorageBlobContent -Container $container -File .\PrivateLinkSettings.csv -Blob "PrivateLinkSettings_$(get-date -f yyyyMMddhhmm).csv" -Context $sa.Context -Force  