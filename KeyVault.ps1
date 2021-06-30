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

$allkvs = Get-AzKeyVault

#------------------------------------KV Table Creation----------------------------------#

Add-Type -AssemblyName 'System.Web'
$KVTable = New-Object System.Data.DataTable
$KVTable.Columns.Add("Name","string") | Out-Null
$KVTable.Columns.Add("ResourceGroup","string") | Out-Null
$KVTable.Columns.Add("Location","string") | Out-Null
$KVTable.Columns.Add("Keys","string") | Out-Null
$KVTable.Columns.Add("Secrets","string") | Out-Null
$KVTable.Columns.Add("Certificates","string") | Out-Null
$KVTable.Columns.Add("AccessPolicies","string") | Out-Null
$KVTable.Columns.Add("SoftDeleteRetentionInDays","string") | Out-Null
$KVTable.Columns.Add("EnabledForDeployment","string") | Out-Null
$KVTable.Columns.Add("EnabledForDiskEncryption","string") | Out-Null
$KVTable.Columns.Add("EnabledForTemplateDeployment","string") | Out-Null
$KVTable.Columns.Add("EnablePurgeProtection","string") | Out-Null
$KVTable.Columns.Add("EnableSoftDelete","string") | Out-Null
$KVTable.Columns.Add("EnableRbacAuthorization","string") | Out-Null

#------------------------------------------------------------------------------------#

foreach($kv in $allkvs)
{
    $kvinfo = Get-AzKeyVault -VaultName $kv.VaultName
    $keys = Get-AzKeyVaultKey -VaultName $kv.VaultName
    $certificates = Get-AzKeyVaultCertificate -VaultName $kv.VaultName
    $secrets = Get-AzKeyVaultSecret -VaultName $kv.VaultName
    $name = $kv.Vaultname
    $rg = $kv.ResourceGroupName
    $location = $kv.Location
    $kvkeys = ""
    foreach($key in $keys.Name)
    {
        $kvkeys = $key+";"+$kvkeys
    }
    $kvsecrets = ""
    foreach($secret in $secrets.Name)
    {
        $kvsecrets = $secret+";"+$kvsecrets
    }
    $kvcerts = ""
    foreach($cert in $certificates.Name)
    {
        $kvcerts = $cert+";"+$kvcerts
    }
    $kvaccess = ""
    foreach($access in $kvinfo.AccessPolicies.ObjectID)
    {
        $kvaccess = $access+";"+$kvaccess
    }
    $retentionpolicy = $kvinfo.SoftDeleteRetentionInDays
    $enablefordeploy = $kvinfo.EnabledForDeployment
    $enablefordiskencryption = $kvinfo.EnabledForDiskEncryption
    $enablefortempdeploy = $kvinfo.EnabledForTemplateDeployment
    $enablepurgeprot = $kvinfo.EnablePurgeProtection
    $enablesoftdelete = $kvinfo.EnableSoftDelete
    $enablerbacauth = $kvinfo.EnableRbacAuthorization

    $kvrow = $KVTable.NewRow()
    $kvrow.Name=$name
    $kvrow.ResourceGroup= $rg
    $kvrow.location=$location
    $kvrow.keys=$kvkeys.TrimEnd(";")
    $kvrow.secrets=$kvsecrets.TrimEnd(";")
    $kvrow.certificates=$kvcerts.TrimEnd(";")
    $kvrow.AccessPolicies=$kvaccess.TrimEnd(";")
    $kvrow.SoftDeleteRetentionInDays=$retentionpolicy
    $kvrow.EnabledForDeployment=$enablefordeploy
    $kvrow.EnabledForDiskEncryption=$enablefordiskencryption
    $kvrow.EnabledForTemplateDeployment=$enablefortempdeploy
    $kvrow.EnablePurgeProtection=$enablepurgeprot
    $kvrow.EnableSoftDelete=$enablesoftdelete
    $kvrow.EnableRbacAuthorization=$enablerbacauth
    $KVTable.Rows.Add($kvrow) | Out-Null
}

#--------------------------------------Output-----------------------------------------#

$KVTable | Export-Csv KeyVaultSettings.csv -NoTypeInformation -Force
Set-AzStorageBlobContent -Container $container -File .\KeyVaultSettings.csv -Blob "KeyVaultSettings_$(get-date -f yyyyMMddhhmm).csv" -Context $sa.Context -Force  