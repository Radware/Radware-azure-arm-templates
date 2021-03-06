#Allow TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
# Set the Execution policy for "RemoteSigned" in order to launch the script
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
# Install Azure resource manager cmdlet
Install-Module -Name AzureRM -AllowClobber


try {
    Get-AzureRmSubscription | Out-Null
    Write-Host "Already logged in"
    }
    catch {
      Write-Host "Not logged in, transfering to login page"
      Login-AzureRmAccount
    }


$parameterFilePath = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Radware/Radware-azure-arm-templates/master/Alteon/CLI/Standalone/Multi%20IP/new-network/app/parameters.json"
$templateFilePath = "https://raw.githubusercontent.com/Radware/Radware-azure-arm-templates/master/Alteon/CLI/Standalone/Multi%20IP/new-network/app/templates.json"


Write-Host "Welcome to radware Alteon Deployment"

$SubIdCount =  Get-AzureRmSubscription | Measure-Object -Line
$SubscriptionName = Get-AzureRmSubscription
 If ($SubIdCount.lines  -eq '1')  {

  $SubscriptionName = Get-AzureRmSubscription

  } Else {

    $linenumber = 1
$SubscriptionName |
   ForEach-Object {New-Object psObject -Property @{'Number'=$linenumber;'Subscription Name'= $_.name;};$linenumber ++ } -outvariable choosemenu | out-null
    
function Show-Menu
{
    param (
        [string]$Title = 'Subscription Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"

    $Menu = @{}

    $choosemenu -replace '@.*Name=' -replace '}' | ForEach-Object -Begin {$i = 1} { 
        Write-Host " $i. $_`  " 
        $Menu.add("$i",$_)
        $i++
    }

    Write-Host "Q: Press 'Q' to quit."

    $SubSelection = Read-Host "Please make a selection"

    if ($SubSelection -eq 'Q') { Return } Else { $Menu.$SubSelection }

}
$SubscriptionName = Show-Menu -Title 'Subscription Choose'
Write-Host "Choosen subscription: $SubscriptionName

"
}
 

Write-Host "Please fill the following parameters"

###Virtual machine name###
$vmname = $(
 $VMNameselection = read-host "Virtual machine name <"$parameterFilePath.parameters.virtualMachineName.value" is default>"
 if ($VMNameselection) {$VMNameselection} else {$parameterFilePath.parameters.virtualMachineName.value}
)
##########################
##########################

###AdminUsername###
$Username = $(
 $adminUsernameselection = read-host "Admin Username <"$parameterFilePath.parameters.adminUsername.value" is default>"
 if ($adminUsernameselection) {$adminUsernameselection} else {$parameterFilePath.parameters.adminUsername.value}
)
##########################
###Virtual machine password###
$parameterFilePath.parameters.adminPassword.value =  Read-Host 'Virtual machine password' -assecurestring

###Resource group name###

$resourceGroupName = $(
 $resourceGroupNameselection = read-host 'Resource group name <AlteonRG is default>'
 if ($resourceGroupNameselection) {$resourceGroupNameselection} else {'AlteonRG'}
)
##########################

###Resource group location###

$resourceGroupLocation = $(
 $resourceGroupLocationselection = read-host 'Resource group location <centralus is default>'
 if ($resourceGroupLocationselection) {$resourceGroupLocationselection} else {'centralus'}
)
##########################

###Vnet name###

$vnetname = $(
$vnetnameselection = read-host "Virtual network name <"$parameterFilePath.parameters.virtualNetworkName.value" is default>"
 if ($vnetnameselection) {$vnetnameselection} else {$parameterFilePath.parameters.virtualNetworkName.value}
)

##########################

###Vnet Address space###
$addrpref = $(
$vnetaddrprefselection = read-host "Vnet address space <"$parameterFilePath.parameters.addressPrefixes.value[0]" is default>"
 if ($vnetaddrprefselection) {$vnetaddrprefselection} else {$parameterFilePath.parameters.addressPrefixes.value[0]}
)
$parameterFilePath.parameters.addressPrefixes.value[0] ="$addrpref"
##########################


###Alteon Subnet name###


$subnetname = $(
$subnetnameselection = read-host "Sunet name <"$parameterFilePath.parameters.subnetName.value" is default>"
 if ($subnetnameselection) {$subnetnameselection} else {$parameterFilePath.parameters.subnetName.value}
)
$parameterFilePath.parameters.subnets.value[0].name = "$subnetname"


##########################


###Alteon Subnet###
$parameterFilePath.parameters.subnets.value[0].properties.addressPrefix = $( $alteonsubnetselection = read-host "Subnet prefix <"$parameterFilePath.parameters.subnets.value[0].properties.addressPrefix" is default>"
 if ("$alteonsubnetselection") {"$alteonsubnetselection"} else {$parameterFilePath.parameters.subnets.value[0].properties.addressPrefix}
)
##########################


$date = date
$stgaccname = $parameterFilePath.parameters.virtualMachineName.value.ToLower() +"diag"+$date.second
$stgaccID = "Microsoft.Storage/storageAccounts/"+$stgaccname
#######################################################

Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace > $null;
}



#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"



# select subscription
Write-Host "Selecting subscription '$SubscriptionName'";
$subid = Get-AzureRmSubscription -SubscriptionName 'Professional Services'
Select-AzureRmSubscription -SubscriptionID $subid.Id > $null;

# Register RPs
$resourceProviders = @("microsoft.compute","microsoft.network","microsoft.storage") > $null;
if($resourceProviders.length) {
   # Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider) > $null;
    }
}



#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup) {
    Write-Host "Resource group '$resourceGroupName' does not exist. Creating now resource group: $resourceGroupName" ;
    if(!$resourceGroupLocation) {
        $resourceGroupLocation
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
} else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# Start the deployment
Write-Host "Starting deployment...";


#################Get Image details#########################
$Alteonimage = Get-AzureRmVMImage -Location $resourceGroupLocation -PublisherName "Radware" -Offer "radware-alteon-va" -Skus "radware-alteon-ng-va-adc"
$Alteonversion = $Alteonimage.Version


################Array converstion##########################
$list = "networkSecurityGroupRules", "subnets"
foreach ($var in $list) {
    $arr = New-Object System.Collections.ArrayList
    For ($i=0; $i -lt $parameterFilePath.parameters.($var).value.Count ; $i++) {
        foreach ($entry in $parameterFilePath.parameters.($var).value[($i)] | Get-Member -MemberType Properties | Select-Object Name ) {
            if (($entry.name) -eq "properties" ) {
                foreach ($entry2 in $parameterFilePath.parameters.($var).value[($i)].($entry.name) | Get-Member -MemberType Properties | Select-Object Name ) {
                    $hasht+=@{($entry2).name = ($parameterFilePath.parameters.($var).value[($i)].($entry.name).($entry2.Name))}
                }
                $arr_tmp += @{properties=$hasht}
                Remove-Variable hasht
            } else {
                $arr_tmp += @{$entry.name = $parameterFilePath.parameters.($var).value[($i)].($entry.name)}
            }
        }
        #$arr_tmp
        $arr+=$arr_tmp
        Remove-Variable arr_tmp        
    }
    New-Variable -Name "$var" -Value $arr
    Remove-Variable arr
}

############################################################

$ParametersObj = @{
    diagnosticsStorageAccountName = $stgaccname
    diagnosticsStorageAccountId = $stgaccID    
    virtualMachineRG = "$resourceGroupName"
    adminUsername = "$Username"
    #adminPassword = $parameterFilePath.parameters.adminPassword.value
    networkSecurityGroupRules = $networkSecurityGroupRules
    addressPrefixes = $parameterFilePath.parameters.addressPrefixes.value
    subnets = $subnets
    networkSecurityGroupName = $parameterFilePath.parameters.networkSecurityGroupName.value
    networkInterfaceName = $parameterFilePath.parameters.networkInterfaceName.value
    virtualNetworkName = "$vnetname"
    virtualMachineName =  "$vmname"
    subnetName = "$subnetname"
    publicIpAddressName = $parameterFilePath.parameters.publicIpAddressName.value
    publicIpAddressType = $parameterFilePath.parameters.publicIpAddressType.value
    publicIpAddressSku = $parameterFilePath.parameters.publicIpAddressSku.value
    osDiskType =  $parameterFilePath.parameters.osDiskType.value
    virtualMachineSize =  $parameterFilePath.parameters.virtualMachineSize.value
    diagnosticsStorageAccountKind = $parameterFilePath.parameters.diagnosticsStorageAccountKind.value
    diagnosticsStorageAccountType = $parameterFilePath.parameters.diagnosticsStorageAccountType.value
    version = $Alteonversion
}




New-AzureRmResourceGroupDeployment -TemplateUri $templateFilePath -TemplateParameterObject $ParametersObj -adminPassword $parameterFilePath.parameters.adminPassword.value  -ResourceGroupName $resourceGroupName -location $resourceGroupLocation;

#########################Alteon Access##################################
$adm = "admin"
$dns = $vmname.ToLower()
Write-Host "Your Alteon will be accessible via:";
Write-Host " ";
Write-Host " ";
Write-Host "https://$dns.$resourceGroupLocation.cloudapp.azure.com:8443/";
Write-Host " ";

Write-Host "When the Alteon will be accsible, it will open automaticly through your default browser";
Write-Host "";
Write-Host " ";


Start-Sleep -Seconds 60 | out-null

$publicIp = Get-AzureRmPublicIpAddress -name alteonpublic-ip -ResourceGroupName $resourceGroupName
$publicIp.DnsSettings = @{"DomainNameLabel" = $dns}
$publicIp.DnsSettings.DomainNameLabel = $dns
Set-AzureRmPublicIpAddress -PublicIpAddress $publicIp

Start-Sleep -Seconds 30 | out-null


## Disable certificate validation
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$credential = New-Object System.Management.Automation.PSCredential( "admin", (ConvertTo-SecureString -String $adm -AsPlainText -Force) )
$counter=0
do {
    $counter++
    try{$response=Invoke-WebRequest "https://$dns.$resourceGroupLocation.cloudapp.azure.com:8443/config" -Method PUT -Body ( ( @{ sysName=$vmname } ) | ConvertTo-Json ) -Credential $credential -UseBasicParsing} catch{$response=@()}
    Start-Sleep -s 5
} until ( $counter -le 360 -or $response.StatusCode -eq 200)  

If ($response.StatusCode -eq 200  ) {
Write-Host "Opening Browser.....";

Start-Process "https://$dns.$resourceGroupLocation.cloudapp.azure.com:8443/"

  }  Else {

  "It's seems like the Alteon is inacssible, Please verify the deployment"
  "If there is any issue with the script, Please open an issue on our GitHub page: https://github.com/Radware/Radware-azure-arm-templates/issues "

} 
