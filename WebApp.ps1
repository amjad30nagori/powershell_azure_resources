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

#---------------All Key Vaults--------------------#

$allwebapps = Get-AzWebApp

#------------------------------------webapp Table Creation----------------------------------#

Add-Type -AssemblyName 'System.Web'
$webappTable = New-Object System.Data.DataTable
$webappTable.Columns.Add("Name","string") | Out-Null
$webappTable.Columns.Add("ResourceGroup","string") | Out-Null
$webappTable.Columns.Add("Location","string") | Out-Null
$webappTable.Columns.Add("Kind","string") | Out-Null
$webappTable.Columns.Add("Type","string") | Out-Null
$webappTable.Columns.Add("HttpsOnly","string") | Out-Null
$webappTable.Columns.Add("DefaultHostName","string") | Out-Null
$webappTable.Columns.Add("TargetSwapSlot","string") | Out-Null
$webappTable.Columns.Add("SlotSwapStatus","string") | Out-Null
$webappTable.Columns.Add("HostNames","string") | Out-Null
$webappTable.Columns.Add("State","string") | Out-Null
$webappTable.Columns.Add("UsageState","string") | Out-Null
$webappTable.Columns.Add("AvailabilityState","string") | Out-Null
$webappTable.Columns.Add("ClientAffinityEnabled","string") | Out-Null
$webappTable.Columns.Add("ClientCertEnabled","string") | Out-Null

#------------------------------------------------------------------------------------#

foreach($webapp in $allwebapps)
{

    $Name=$webapp.Name
    $ResourceGroup=$webapp.ResourceGroup
    $Location=$webapp.Location
    $Kind=$webapp.Kind
    $Type=$webapp.Type
    $HttpsOnly=$webapp.HttpsOnly
    $DefaultHostName=$webapp.DefaultHostName
    $TargetSwapSlot=$webapp.TargetSwapSlot
    $SlotSwapStatus=$webapp.SlotSwapStatus
    $hostnames = ""
    foreach($hostname in $webapp.HostNames)
    {
        $hostnames = $hostname+";"+$hostnames
    }
    $State=$webapp.State
    $UsageState=$webapp.UsageState
    $AvailabilityState=$webapp.AvailabilityState
    $ClientAffinityEnabled=$webapp.ClientAffinityEnabled
    $ClientCertEnabled=$webapp.ClientCertEnabled

    $webapprow = $webappTable.NewRow()
    $webapprow.Name=$Name
    $webapprow.ResourceGroup= $ResourceGroup
    $webapprow.Location=$Location
    $webapprow.Kind=$Kind
    $webapprow.Type=$Type
    $webapprow.HttpsOnly=$HttpsOnly
    $webapprow.DefaultHostName=$DefaultHostName
    $webapprow.TargetSwapSlot=$TargetSwapSlot
    $webapprow.SlotSwapStatus=$SlotSwapStatus
    $webapprow.HostNames=$hostnames.TrimStart(";")
    $webapprow.State=$State
    $webapprow.UsageState=$UsageState
    $webapprow.AvailabilityState=$AvailabilityState
    $webapprow.ClientAffinityEnabled=$ClientAffinityEnabled
    $webapprow.ClientCertEnabled=$ClientCertEnabled
    $webappTable.Rows.Add($webapprow) | Out-Null
}

#--------------------------------------Output-----------------------------------------#

$webappTable | Export-Csv WebAppSettings.csv -NoTypeInformation -Force
Set-AzStorageBlobContent -Container $container -File .\WebAppSettings.csv -Blob "WebAppSettings_$(get-date -f yyyyMMddhhmm).csv" -Context $sa.Context -Force  