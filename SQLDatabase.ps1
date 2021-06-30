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

#---------------All SQL Databases--------------------#

$allsqls = Get-AzSqlServer

#------------------------------------SQL Table Creation----------------------------------#

Add-Type -AssemblyName 'System.Web'
$SQLTable = New-Object System.Data.DataTable
$SQLTable.Columns.Add("Name","string") | Out-Null
$SQLTable.Columns.Add("ResourceGroup","string") | Out-Null
$SQLTable.Columns.Add("Location","string") | Out-Null
$SQLTable.Columns.Add("ServerName","string") | Out-Null
$SQLTable.Columns.Add("AdminUser","string") | Out-Null
$SQLTable.Columns.Add("Edition","string") | Out-Null
$SQLTable.Columns.Add("Collation","string") | Out-Null
$SQLTable.Columns.Add("MaxSizeMbs","string") | Out-Null
$SQLTable.Columns.Add("Status","string") | Out-Null
$SQLTable.Columns.Add("PublicAccess","string") | Out-Null
$SQLTable.Columns.Add("CreationDate","string") | Out-Null
$SQLTable.Columns.Add("ElasticPool","string") | Out-Null
$SQLTable.Columns.Add("EarlierRestore","string") | Out-Null
$SQLTable.Columns.Add("ZoneRedundant","string") | Out-Null
$SQLTable.Columns.Add("Capacity","string") | Out-Null
$SQLTable.Columns.Add("SKU","string") | Out-Null
$SQLTable.Columns.Add("BackupRedundancy","string") | Out-Null

#------------------------------------------------------------------------------------#

foreach($SQL in $allsqls)
{
    $sqldbs = Get-AzSqlDatabase -ServerName $SQL.ServerName -ResourceGroupName $SQL.ResourceGroupName -WarningAction Ignore
    foreach($db in $sqldbs)
    {
        $name = $db.DatabaseName
        $rg = $db.ResourceGroupName
        $location = $db.Location
        $server = $db.ServerName
        $adminuser = $sql.SqlAdministratorLogin
        $edition = $db.Edition
        $collation = $db.CollationName
        $maxsizembs = $db.MaxSizeBytes/(1024*1024)
        $status = $db.status
        $publicaccess = $sql.PublicNetworkAccess
        $creationdate = $db.CreationDate
        $elasticpool = $db.ElasticPoolName
        $earlierrestore = $db.EarliestRestoreDate
        $zoneredundant = $db.ZoneRedundant
        $capacity = $db.Capacity
        $sku = $db.SkuName
        $backupredundancy = $db.BackupStorageRedundancy

        $SQLrow = $SQLTable.NewRow()
        $SQLrow.Name=$name
        $SQLrow.ResourceGroup= $rg
        $SQLrow.location=$location
        $SQLrow.ServerName=$server
        $SQLrow.AdminUser=$adminuser
        $SQLrow.Edition=$edition
        $SQLrow.Collation=$collation
        $SQLrow.MaxSizeMbs=$maxsizembs
        $SQLrow.Status=$status
        $SQLrow.PublicAccess=$publicaccess
        $SQLrow.CreationDate=$creationdate
        $SQLrow.ElasticPool=$elasticpool
        $SQLrow.EarlierRestore=$earlierrestore
        $SQLrow.ZoneRedundant=$zoneredundant
        $SQLrow.Capacity=$capacity
        $SQLrow.SKU=$sku
        $SQLrow.BackupRedundancy=$backupredundancy
        $SQLTable.Rows.Add($SQLrow) | Out-Null
    }
}

#--------------------------------------Output-----------------------------------------#

$SQLTable | Export-Csv SQLDatabaseSettings.csv -NoTypeInformation -Force
Set-AzStorageBlobContent -Container $container -File .\SQLDatabaseSettings.csv -Blob "SQLDatabaseSettings_$(get-date -f yyyyMMddhhmm).csv" -Context $sa.Context -Force  