#--------------Storage Account Information---------#

$storageaccount = "csg100320014a90a68c"
$storageaccountrg = "cloud-shell-storage-centralindia"
$container = "az-resource-settings"

#--------------Storage Account---------------------#

$sa = Get-AzStorageAccount -Name $storageaccount -ResourceGroupName $storageaccountrg

#---------------All Key Vaults--------------------#

$alldatafactory = Get-AzDataFactoryV2

#------------------------------------DataFac Table Creation----------------------------------#

Add-Type -AssemblyName 'System.Web'
$DataFacTable = New-Object System.Data.DataTable
$DataFacTable.Columns.Add("Name","string") | Out-Null
$DataFacTable.Columns.Add("ResourceGroup","string") | Out-Null
$DataFacTable.Columns.Add("Location","string") | Out-Null
$DataFacTable.Columns.Add("RepoHostName","string") | Out-Null
$DataFacTable.Columns.Add("RepoAccountName","string") | Out-Null
$DataFacTable.Columns.Add("RepositoryName","string") | Out-Null
$DataFacTable.Columns.Add("RepoCollaborationBranch","string") | Out-Null
$DataFacTable.Columns.Add("RepoRootFolder","string") | Out-Null
$DataFacTable.Columns.Add("RepoLastCommitId","string") | Out-Null

#------------------------------------------------------------------------------------#

foreach($DataFac in $alldatafactory)
{

    $Name=$DataFac.DataFactoryName
    $ResourceGroup=$DataFac.ResourceGroupName
    $Location=$DataFac.Location
    $RepoHostName=$DataFac.RepoConfiguration.HostName
    $RepoAccountName=$DataFac.RepoConfiguration.AccountName
    $RepositoryName=$DataFac.RepoConfiguration.RepositoryName
    $RepoCollaborationBranch=$DataFac.RepoConfiguration.CollaborationBranch
    $RepoRootFolder=$DataFac.RepoConfiguration.RootFolder
    $RepoLastCommitId=$DataFac.RepoConfiguration.LastCommitId

    $DataFacrow = $DataFacTable.NewRow()
    $DataFacrow.Name=$Name
    $DataFacrow.ResourceGroup= $ResourceGroup
    $DataFacrow.Location=$Location
    $DataFacrow.RepoHostName=$RepoHostName
    $DataFacrow.RepoAccountName=$RepoAccountName
    $DataFacrow.RepositoryName=$RepositoryName
    $DataFacrow.RepoCollaborationBranch=$RepoCollaborationBranch
    $DataFacrow.RepoRootFolder=$RepoRootFolder
    $DataFacrow.RepoLastCommitId=$RepoLastCommitId
    $DataFacTable.Rows.Add($DataFacrow) | Out-Null
}

#--------------------------------------Output-----------------------------------------#

$DataFacTable | Export-Csv DataFactorySettings.csv -NoTypeInformation -Force
Set-AzStorageBlobContent -Container $container -File .\DataFactorySettings.csv -Blob "DataFactorySettings_$(get-date -f yyyyMMddhhmm).csv" -Context $sa.Context -Force  