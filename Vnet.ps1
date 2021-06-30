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

#---------------Virtual Network--------------------#

$allvnets = Get-AzVirtualNetwork

#------------------------------------Vnet Table Creation----------------------------------#

Add-Type -AssemblyName 'System.Web'
$VnetTable = New-Object System.Data.DataTable
$VnetTable.Columns.Add("Name","string") | Out-Null
$VnetTable.Columns.Add("ResourceGroup","string") | Out-Null
$VnetTable.Columns.Add("Location","string") | Out-Null
$VnetTable.Columns.Add("AddressSpace","string") | Out-Null
$VnetTable.Columns.Add("ConnectedDevice","string") | Out-Null     # subnet level
$VnetTable.Columns.Add("Subnet","string") | Out-Null
$VnetTable.Columns.Add("DDoS","string") | Out-Null
#$VnetTable.Columns.Add("Firewall","string") | Out-Null            # firewall level
$VnetTable.Columns.Add("DNS","string") | Out-Null
$VnetTable.Columns.Add("Peering","string") | Out-Null
$VnetTable.Columns.Add("ServiceEndpoint","string") | Out-Null     #subnet level
$VnetTable.Columns.Add("PrivateEndpoint","string") | Out-Null     #subnet level

#------------------------------------------------------------------------------------#

foreach($vnet in $allvnets)
{

    $name = $vnet.Name
    $rg = $vnet.ResourceGroupName
    $location = $vnet.Location
    $ddos = $vnet.EnableDdosProtection
    $addspaces = ""
    foreach($address in $vnet.AddressSpace.AddressPrefixes)
        {
            $addspaces = $address+";"+$addspaces
        }
    $subnets = ""
    $connectedevices=""
    $serviceeps = ""
    $privateeps = ""
    foreach($subnet in $vnet.Subnets)
        {
            $subnets = $subnet.name+";"+$subnets
                foreach($connectedevice in $subnet.IpConfigurations.Id)
                {
                    $connectedevices = $connectedevice.Split("/")[10]+";"+$connectedevices
                }
                foreach($serviceep in $subnet.ServiceEndpoints.Service)
                {
                    $serviceeps = $subnet.name+"="+$serviceep+";"+$serviceeps
                }
                foreach($privateep in $subnet.PrivateEndpoints.Id)
                {
                    $privateeps = $subnet.name+"="+$privateep.Split("/")[8]+";"+$privateeps
                }

        }
    $dnses = ""
    foreach($dns in $vnet.DhcpOptions.DnsServers)
        {
            $dnses = $dns+";"+$dnses
        }
    $peerings = ""
    foreach($peer in $vnet.VirtualNetworkPeerings.Name)
        {
            $peerings = $peer+";"+$peerings
        }


    $vnetrow = $VnetTable.NewRow()
    $vnetrow.Name=$name
    $vnetrow.ResourceGroup= $rg
    $vnetrow.location=$location
    $vnetrow.AddressSpace=$addspaces.TrimEnd(";")
    $vnetrow.Subnet=$subnets.TrimEnd(";")
    $vnetrow.DDoS=$ddos
    $vnetrow.DNS=$dnses.TrimEnd(";")
    $vnetrow.peering=$peerings.TrimEnd(";")
    $vnetrow.ConnectedDevice=$connectedevices.TrimEnd(";")
    $vnetrow.ServiceEndpoint=$serviceeps.TrimEnd(";")
    $vnetrow.PrivateEndpoint=$privateeps.TrimEnd(";")
    $VnetTable.Rows.Add($vnetrow) | Out-Null
}

#--------------------------------------Output-----------------------------------------#

$VnetTable | Export-Csv VnetSettings.csv -NoTypeInformation -Force
Set-AzStorageBlobContent -Container $container -File .\VnetSettings.csv -Blob "VnetSettings_$(get-date -f yyyyMMddhhmm).csv" -Context $sa.Context -Force  