#--------------Connect Azure Run As Account--------------#

$connectionName = "AzureRunAsConnection"
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         
    "Logging in to Azure..."
    Add-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 

#--------------Storage Account Parameters---------#

$storageaccount = "amjstorage124"
$storageaccountrg = "amjad"
$container = "az-resource-settings"

#--------------Storage Account---------------------#

$sa = Get-AzStorageAccount -Name $storageaccount -ResourceGroupName $storageaccountrg

#---------------All Resource Groups--------------------#

$allrgs = Get-AzResourceGroup

#---------------Cosmos Table Creation------------------------#

Add-Type -AssemblyName 'System.Web'
$cosmosTable = New-Object System.Data.DataTable
$cosmosTable.Columns.Add("Name","string") | Out-Null
$cosmosTable.Columns.Add("ResourceGroup","string") | Out-Null
$cosmosTable.Columns.Add("Location","string") | Out-Null
$cosmosTable.Columns.Add("API","string") | Out-Null
$cosmosTable.Columns.Add("EnableMultipleWriteLocations","string") | Out-Null
$cosmosTable.Columns.Add("FailoverPolicies","string") | Out-Null
$cosmosTable.Columns.Add("Locations","string") | Out-Null
$cosmosTable.Columns.Add("ReadLocations","string") | Out-Null
$cosmosTable.Columns.Add("WriteLocations","string") | Out-Null
$cosmosTable.Columns.Add("Capabilities","string") | Out-Null
$cosmosTable.Columns.Add("EnableAutomaticFailover","string") | Out-Null
$cosmosTable.Columns.Add("IsVirtualNetworkFilterEnabled","string") | Out-Null
$cosmosTable.Columns.Add("DatabaseAccountOfferType","string") | Out-Null
$cosmosTable.Columns.Add("DocumentEndpoint","string") | Out-Null
$cosmosTable.Columns.Add("Kind","string") | Out-Null
$cosmosTable.Columns.Add("PublicNetworkAccess","string") | Out-Null
$cosmosTable.Columns.Add("EnableAnalyticalStorage","string") | Out-Null
$cosmosTable.Columns.Add("BackupPolicy","string") | Out-Null


#------------------------------------------------------------------------------------#
foreach($rg in $allrgs)
{
    $allcosmosdb = Get-AzCosmosDBAccount -ResourceGroupName $rg.ResourceGroupName
    foreach($cosmos in $allcosmosdb)
    {
        $Name = $cosmos.Name
        $ResourceGroup = $rg.ResourceGroupName
        $Location = $cosmos.Location
        $API = $cosmos.Tags.defaultExperience
        $EnableMultipleWriteLocations = $cosmos.EnableMultipleWriteLocations

        $fvpolicies = ""
        foreach($fvpolicy in $cosmos.FailoverPolicies.Id)
        {
            $fvpolicies = $fvpolicy+";"+$fvpolicies
        }
        $locations = ""
        foreach($loc in $cosmos.Locations.LocationName)
        {
            $locations = $loc+";"+$locations
        }
        $readlocations = ""
        foreach($readloc in $cosmos.ReadLocations.Id)
        {
            $readlocations = $readloc+";"+$readlocations
        }
        $writelocations = ""
        foreach($writeloc in $cosmos.WriteLocations.Id)
        {
            $writelocations = $writeloc+";"+$writelocations
        }
        $capabs = ""
        foreach($cap in $cosmos.Capabilities.Name)
        {
            $capabs = $cap+";"+$capabs
        }
               
        $EnableAutomaticFailover = $cosmos.EnableAutomaticFailover
        $IsVirtualNetworkFilterEnabled = $cosmos.IsVirtualNetworkFilterEnabled
        $DatabaseAccountOfferType = $cosmos.DatabaseAccountOfferType
        $DocumentEndpoint = $cosmos.DocumentEndpoint
        $Kind = $cosmos.Kind
        $PublicNetworkAccess = $cosmos.PublicNetworkAccess
        $EnableAnalyticalStorage = $cosmos.EnableAnalyticalStorage
        $BackupPolicy = $cosmos.BackupPolicy

        $cosmosrow = $cosmosTable.NewRow()
        $cosmosrow.Name=$Name
        $cosmosrow.ResourceGroup= $ResourceGroup
        $cosmosrow.Location=$Location
        $cosmosrow.API=$API
        $cosmosrow.EnableMultipleWriteLocations=$EnableMultipleWriteLocations
        $cosmosrow.FailoverPolicies=$fvpolicies.TrimEnd(";")
        $cosmosrow.Locations=$locations.TrimEnd(";")
        $cosmosrow.ReadLocations=$readlocations.TrimEnd(";")
        $cosmosrow.WriteLocations=$writelocations.TrimEnd(";")
        $cosmosrow.Capabilities=$capabs.TrimEnd(";")
        $cosmosrow.EnableAutomaticFailover=$EnableAutomaticFailover
        $cosmosrow.IsVirtualNetworkFilterEnabled=$IsVirtualNetworkFilterEnabled
        $cosmosrow.DatabaseAccountOfferType=$DatabaseAccountOfferType
        $cosmosrow.DocumentEndpoint=$DocumentEndpoint
        $cosmosrow.Kind=$Kind
        $cosmosrow.PublicNetworkAccess=$PublicNetworkAccess
        $cosmosrow.EnableAnalyticalStorage=$EnableAnalyticalStorage
        $cosmosrow.BackupPolicy=$BackupPolicy
        $cosmosTable.Rows.Add($cosmosrow) | Out-Null
    }
}
#--------------------------------------Output-----------------------------------------#

$cosmosTable | Export-Csv CosmosSettings.csv -NoTypeInformation -Force
Set-AzStorageBlobContent -Container $container -File .\CosmosSettings.csv -Blob "CosmosSettings_$(get-date -f yyyyMMddhhmm).csv" -Context $sa.Context -Force  