#--------------Connect Azure Run As Account--------------#

$connectionName = "AzureRunAsConnection"
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         
    "Logging in to Azure..."
    Add-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 

#--------------Storage Account Information---------#

$storageaccount = "amjstorage124"
$storageaccountrg = "amjad"
$container = "az-resource-settings"

#--------------Storage Account---------------------#

$sa = Get-AzStorageAccount -Name $storageaccount -ResourceGroupName $storageaccountrg

#---------------All Storages--------------------#

$allstgs = Get-AzStorageAccount

#------------------------------------Storage Account Table Creation----------------------------------#

Add-Type -AssemblyName 'System.Web'
$StorageTable = New-Object System.Data.DataTable
$StorageTable.Columns.Add("Name","string") | Out-Null
$StorageTable.Columns.Add("ResourceGroup","string") | Out-Null
$StorageTable.Columns.Add("Location","string") | Out-Null
$StorageTable.Columns.Add("Kind","string") | Out-Null
$StorageTable.Columns.Add("Performace","string") | Out-Null
$StorageTable.Columns.Add("SecureTransfer","string") | Out-Null
$StorageTable.Columns.Add("AllowBlobPublicAccess","string") | Out-Null
$StorageTable.Columns.Add("AllowStorageKeyAccess","string") | Out-Null
$StorageTable.Columns.Add("MinTLSVersion","string") | Out-Null
$StorageTable.Columns.Add("AccessTier","string") | Out-Null
$StorageTable.Columns.Add("Replication","string") | Out-Null
$StorageTable.Columns.Add("LargeFileShare","string") | Out-Null

#------------------------------------------------------------------------------------#

foreach($stg in $allstgs)
{

    $name = $stg.StorageAccountName
    $rg = $stg.ResourceGroupName
    $location = $stg.Location
    $kind = $stg.Kind
    $performance = $stg.Sku.Tier
    $securetransfer = $stg.EnableHttpsTrafficOnly
    $allowblobpa = $stg.AllowBlobPublicAccess
    $allowska = $stg.AllowSharedKeyAccess
    $mintls = $stg.MinimumTlsVersion
    $accesstier = $stg.AccessTier
    $replication = $stg.sku.name
    $largefile = $stg.LargeFileSharesState

    $stgrow = $StorageTable.NewRow()
    $stgrow.Name=$name
    $stgrow.ResourceGroup= $rg
    $stgrow.location=$location
    $stgrow.Kind=$kind
    $stgrow.Performace = $performance
    $stgrow.SecureTransfer = $securetransfer
    $stgrow.AllowBlobPublicAccess = $allowblobpa
    $stgrow.AllowStorageKeyAccess = $allowska
    $stgrow.MinTLSVersion = $mintls
    $stgrow.AccessTier = $accesstier
    $stgrow.Replication = $replication
    $stgrow.LargeFileShare = $largefile
    $StorageTable.Rows.Add($stgrow) | Out-Null
}

#--------------------------------------Output-----------------------------------------#

$StorageTable | Export-Csv StorageAccSettings.csv -NoTypeInformation -Force
Set-AzStorageBlobContent -Container $container -File .\StorageAccSettings.csv -Blob "StorageAccSettings_$(get-date -f yyyyMMddhhmm).csv" -Context $sa.Context -Force  