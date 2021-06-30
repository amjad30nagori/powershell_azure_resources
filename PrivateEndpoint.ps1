#--------------Storage Account Information---------#

$storageaccount = "csg100320014a90a68c"
$storageaccountrg = "cloud-shell-storage-centralindia"
$container = "az-resource-settings"

#--------------Storage Account---------------------#

$sa = Get-AzStorageAccount -Name $storageaccount -ResourceGroupName $storageaccountrg

#---------------All Key Vaults--------------------#

$allprivateep = Get-AzPrivateEndpoint

#------------------------------------privep Table Creation----------------------------------#

Add-Type -AssemblyName 'System.Web'
$privepTable = New-Object System.Data.DataTable
$privepTable.Columns.Add("Name","string") | Out-Null
$privepTable.Columns.Add("ResourceGroup","string") | Out-Null
$privepTable.Columns.Add("Location","string") | Out-Null
$privepTable.Columns.Add("Type","string") | Out-Null
$privepTable.Columns.Add("VirtualNetwork","string") | Out-Null
$privepTable.Columns.Add("Subnet","string") | Out-Null
$privepTable.Columns.Add("IPAddress","string") | Out-Null
$privepTable.Columns.Add("FQDN","string") | Out-Null
$privepTable.Columns.Add("Resource","string") | Out-Null
$privepTable.Columns.Add("ResourceSubGroup","string") | Out-Null

#------------------------------------------------------------------------------------#

foreach($privep in $allprivateep)
{

    $Name=$privep.Name
    $ResourceGroup=$privep.ResourceGroupName
    $Location=$privep.Location
    $Type=$privep.Type
    $VirtualNetwork=$privep.Subnet.id.Split("/")[8]
    $Subnet=$privep.Subnet.id.Split("/")[10]
    $IPAddress=$privep.CustomDnsConfigs.IpAddresses
    $FQDN=$privep.CustomDnsConfigs.FQDN
    $Resource=$privep.PrivateLinkServiceConnections.PrivateLinkServiceId.Split("/")[8]
    $ResourceSubGroup=$privep.PrivateLinkServiceConnections.groupids

    $priveprow = $privepTable.NewRow()
    $priveprow.Name=$Name
    $priveprow.ResourceGroup= $ResourceGroup
    $priveprow.Location=$Location
    $priveprow.Type=$Type
    $priveprow.VirtualNetwork=$VirtualNetwork
    $priveprow.Subnet=$Subnet
    $priveprow.IPAddress=$IPAddress
    $priveprow.FQDN=$FQDN
    $priveprow.Resource=$Resource
    $priveprow.ResourceSubGroup=$ResourceSubGroup
    $privepTable.Rows.Add($priveprow) | Out-Null
}

#--------------------------------------Output-----------------------------------------#

$privepTable | Export-Csv PrivEPSettings.csv -NoTypeInformation -Force
Set-AzStorageBlobContent -Container $container -File .\PrivEPSettings.csv -Blob "PrivEPSettings_$(get-date -f yyyyMMddhhmm).csv" -Context $sa.Context -Force  