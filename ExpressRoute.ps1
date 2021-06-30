#--------------Storage Account Information---------#

$storageaccount = "csg100320014a90a68c"
$storageaccountrg = "cloud-shell-storage-centralindia"
$container = "az-resource-settings"

#--------------Storage Account---------------------#

$sa = Get-AzStorageAccount -Name $storageaccount -ResourceGroupName $storageaccountrg

#---------------All Key Vaults--------------------#

$allexpressroute = Get-AzExpressRouteCircuit -WarningAction Ignore

#------------------------------------ExpRoute Table Creation----------------------------------#

Add-Type -AssemblyName 'System.Web'
$ExpRouteTable = New-Object System.Data.DataTable
$ExpRouteTable.Columns.Add("Name","string") | Out-Null
$ExpRouteTable.Columns.Add("ResourceGroup","string") | Out-Null
$ExpRouteTable.Columns.Add("Location","string") | Out-Null
$ExpRouteTable.Columns.Add("SKUName","string") | Out-Null
$ExpRouteTable.Columns.Add("SKUTier","string") | Out-Null
$ExpRouteTable.Columns.Add("SKUFamily","string") | Out-Null
$ExpRouteTable.Columns.Add("CircuitProvisioningState","string") | Out-Null
$ExpRouteTable.Columns.Add("ServiceProviderProvisioningState","string") | Out-Null
$ExpRouteTable.Columns.Add("ServiceProviderNotes","string") | Out-Null
$ExpRouteTable.Columns.Add("ServiceProviderName","string") | Out-Null
$ExpRouteTable.Columns.Add("PeeringLocation","string") | Out-Null
$ExpRouteTable.Columns.Add("BandwidthInMbps","string") | Out-Null
$ExpRouteTable.Columns.Add("ExpressRoutePort","string") | Out-Null
$ExpRouteTable.Columns.Add("ServiceKey","string") | Out-Null
$ExpRouteTable.Columns.Add("AllowClassicOperations","string") | Out-Null

#------------------------------------------------------------------------------------#

foreach($ExpRoute in $allexpressroute)
{

    $Name=$ExpRoute.Name
    $ResourceGroup=$ExpRoute.ResourceGroupName
    $Location=$ExpRoute.Location
    $SKUName=$ExpRoute.Sku.Name
    $SKUTier=$ExpRoute.Sku.Tier
    $SKUFamily=$ExpRoute.Sku.Family
    $CircuitProvisioningState=$ExpRoute.CircuitProvisioningState
    $ServiceProviderProvisioningState=$ExpRoute.ServiceProviderProvisioningState
    $ServiceProviderNotes=$ExpRoute.ServiceProviderNotes
    $ServiceProviderName=$ExpRoute.ServiceProviderProperties.ServiceProviderName
    $PeeringLocation=$ExpRoute.ServiceProviderProperties.PeeringLocation
    $BandwidthInMbps=$ExpRoute.ServiceProviderProperties.BandwidthInMbps
    $ExpressRoutePort=$ExpRoute.ExpressRoutePort
    $ServiceKey=$ExpRoute.ServiceKey
    $AllowClassicOperations=$ExpRoute.AllowClassicOperations

    $ExpRouterow = $ExpRouteTable.NewRow()
    $ExpRouterow.Name=$Name
    $ExpRouterow.ResourceGroup= $ResourceGroup
    $ExpRouterow.Location=$Location
    $ExpRouterow.SKUName=$SKUName
    $ExpRouterow.SKUTier=$SKUTier
    $ExpRouterow.SKUFamily=$SKUFamily
    $ExpRouterow.CircuitProvisioningState=$CircuitProvisioningState
    $ExpRouterow.ServiceProviderProvisioningState=$ServiceProviderProvisioningState
    $ExpRouterow.ServiceProviderNotes=$ServiceProviderNotes
    $ExpRouterow.ServiceProviderName=$ServiceProviderName
    $ExpRouterow.PeeringLocation=$PeeringLocation
    $ExpRouterow.BandwidthInMbps=$BandwidthInMbps
    $ExpRouterow.ExpressRoutePort=$ExpressRoutePort
    $ExpRouterow.ServiceKey=$ServiceKey
    $ExpRouterow.AllowClassicOperations=$AllowClassicOperations
    $ExpRouteTable.Rows.Add($ExpRouterow) | Out-Null
}

#--------------------------------------Output-----------------------------------------#

$ExpRouteTable | Export-Csv ExpressRouteSettings.csv -NoTypeInformation -Force
Set-AzStorageBlobContent -Container $container -File .\ExpressRouteSettings.csv -Blob "ExpressRouteSettings_$(get-date -f yyyyMMddhhmm).csv" -Context $sa.Context -Force  