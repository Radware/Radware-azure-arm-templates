Write-Host "Welcome to Radware Alteon High Avilability Deployment"

# Set the Execution policy for "RemoteSigned" in order to launch the script
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
# Install Azure resource manager cmdlet
Install-Module -Name AzureRM -AllowClobber

Write-Host "Checking if you loged in to Azure.."
try {
    Get-AzureRmSubscription | Out-Null
    Write-Host "Already logged in"
    }
    catch {
      Write-Host "Not logged in, transfering to login page"
      Login-AzureRmAccount
    }


$parameterFilePath = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Radware/Radware-azure-arm-templates/master/Alteon/CLI/High-Avilability/SingleIP/new-network/app/parameters.json"
$templateFilePath = "https://raw.githubusercontent.com/Radware/Radware-azure-arm-templates/master/Alteon/CLI/High-Avilability/SingleIP/new-network/app/template.json"




$SubIdCount =  Get-AzureRmSubscription | Measure-Object -Line
$Subid = Get-AzureRmSubscription
 If ($SubIdCount.lines  -eq '1')  {

  $Subid = Get-AzureRmSubscription

  } Else {

    $linenumber = 1
$Subid |
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

    $SubSelection = Read-Host "Please select the Subscription you wish to use"

    if ($SubSelection -eq 'Q') { Return } Else { $Menu.$SubSelection }

}
$SubscriptionName = Show-Menu -Title 'Subscription Menu'
Write-Host "The selected subscription was: $SubscriptionName"
}
 
$admpw = convertto-securestring $parameterFilePath.parameters.adminPassword.value -asplaintext -force

Write-Host "Please fill the following parameters"

###Virtual machine name###
$vmname = $(
 $VMNameselection = read-host "Virtual machine name (VA name will be prefix followed by a number 1 or 2) <"$parameterFilePath.parameters.VMPrefixName.value" is default>"
 if ($VMNameselection) {$VMNameselection} else {$parameterFilePath.parameters.VMPrefixName.value}
)
##########################

###Resource group name###

$resourceGroupName = $(
 $resourceGroupNameselection = read-host 'Resource group name <AlteonRG is default>'
 if ($resourceGroupNameselection) {$resourceGroupNameselection} else {'AlteonRG'}
)
##########################

###Resource group location###

$location = Get-Azurermlocation | Select-Object -Property Location
$linenumber = 1
$location |
   ForEach-Object {New-Object psObject -Property @{'Number'=$linenumber;'Location'= $_.location;};$linenumber ++ } -outvariable choosemenu | out-null
    
function Show-Menu
{
    param (
        [string]$Title = 'Please select the location you wish to use'
    )
    Clear-Host
    Write-Host "================ $Title ================"

    $Menu = @{}

    $choosemenu -replace '@.*Location=' -replace '}' | ForEach-Object -Begin {$i = 1} { 
        Write-Host " $i. $_`  " 
        $Menu.add("$i",$_)
        $i++
    }

    Write-Host "Q: Press 'Q' to quit."

    $LocSelection = Read-Host "Please make a selection"

    if ($LocSelection -eq 'Q') { Return } Else { $Menu.$LocSelection }
}

$resourceGroupLocation = Show-Menu -Title 'Location  Menu'
Write-Host "The selected location was: $resourceGroupLocation"




##########################



###DNS Name for public IP 1###
$dnsNameForPublicIP1 = $(
 $dnsNameForPublicIP1selection = read-host "Specify DNS name for PublicIP1  <"$parameterFilePath.parameters.dnsNameForPublicIP1.value" is default>"
 if ($dnsNameForPublicIP1selection) {$dnsNameForPublicIP1selection} else {$parameterFilePath.parameters.dnsNameForPublicIP1.value}
)
##########################

###DNS Name for public IP 2###
$dnsNameForPublicIP2 = $(
 $dnsNameForPublicIP2selection = read-host "Specify DNS name for PublicIP2  <"$parameterFilePath.parameters.dnsNameForPublicIP2.value" is default>"
 if ($dnsNameForPublicIP2selection) {$dnsNameForPublicIP2selection} else {$parameterFilePath.parameters.dnsNameForPublicIP2.value}
)
##########################
###DNSServerIP###
$DNSServerIP = $(
 $DNSServerIPselection = read-host "Specify Public DNS server  <"$parameterFilePath.parameters.DNSServerIP.value" is default>"
 if ($DNSServerIPselection) {$DNSServerIPselection} else {$parameterFilePath.parameters.DNSServerIP.value}
)

##########################

$date = date
$stgaccname = $parameterFilePath.parameters.VMPrefixName.value.ToLower() +"diag"+$date.second
#######################################################

Write-Host "Please provide the following parameters for High avilability:"
Start-Sleep -Seconds 5 | out-null
$DisplayName = Read-Host "Specify DisplayName (For example: "AlteonHA")"
$HomePage =  Read-Host "Specify HomePage (For example: "https://ha.radware.com/alteon")"
$IdentifierUris = Read-Host "Specify Identifier URL (For example: "https://ha.radware.com/alteon")"
$ClientSecret = Read-Host 'Specify Client Password' -AsSecureString


$AzureSubscriptionName = Get-AzureRmSubscription -SubscriptionName $SubscriptionName 
$AzureSubscriptionName| Select-AzureRmSubscription | out-null
$AppReg = New-AzureRmADApplication -DisplayName $DisplayName -HomePage $HomePage -IdentifierUris  $IdentifierUris -Password $ClientSecret
$ClientID = $AppReg.ApplicationId.Guid
New-AzureRmADServicePrincipal -ApplicationId $ClientID 
Write-Output 'Waiting for ClientID registration'
Start-Sleep -Seconds 40 | out-null
New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $ClientID | out-null



#####################################################################################################################




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
Select-AzureRmSubscription -SubscriptionID $SubscriptionName > $null;

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
    Write-Host "Resource group '$resourceGroupName' does not exist in location '$resourceGroupLocation'. Creating now resource group: $resourceGroupName" ;
    if(!$resourceGroupLocation) {
        $resourceGroupLocation
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation 
} else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}


Write-Host "When the deployment will be completed, Your alteons will be avilable at:";
Write-Host "";
Write-Host "";
Write-Host "https://$dnsNameForPublicIP1.$resourceGroupLocation.cloudapp.azure.com:8443/";
Write-Host "https://$dnsNameForPublicIP2.$resourceGroupLocation.cloudapp.azure.com:8443/";

# Start the deployment
Write-Host "Starting deployment...";




$ParametersObj = @{
    storageAccountName = $stgaccname
    ClientID = "$ClientID"
    TenantID = "$AzureSubscriptionName.TenantID"
    dnsNameForPublicIP1 = "$dnsNameForPublicIP1"
    dnsNameForPublicIP2 = "$dnsNameForPublicIP2"
    DNSServerIP = "$DNSServerIP"  
    vmCount = $parameterFilePath.parameters.vmCount.value
    VMPrefixName =  "$vmname"
    vmSize =  $parameterFilePath.parameters.vmSize.value
}




New-AzureRmResourceGroupDeployment -TemplateUri $templateFilePath -TemplateParameterObject $ParametersObj -adminPassword $admpw -adminUsername $parameterFilePath.parameters.adminUsername.value  -ResourceGroupName $resourceGroupName -location $resourceGroupLocation -ClientSecret $ClientSecret



Write-Host "Your alteon's is accessible via:";
Write-Host "";
Write-Host "";
Write-Host "https://$dnsNameForPublicIP1.$resourceGroupLocation.cloudapp.azure.com:8443/";
Write-Host "https://$dnsNameForPublicIP2.$resourceGroupLocation.cloudapp.azure.com:8443/";




Write-Host "If Internet explorer is installed on your station, It will open autmaticly and browse to your Alteon's:";

Write-Host "Opening Internet Expolrer.....";
Start-Sleep -Seconds 2 | out-null

$OpenInBackgroundTab = 0x1000;
$OpenIE=new-object -com internetexplorer.application
$OpenIE.navigate2("https://$dnsNameForPublicIP1.$resourceGroupLocation.cloudapp.azure.com:8443/")
$OpenIE.navigate2("https://$dnsNameForPublicIP2.$resourceGroupLocation.cloudapp.azure.com:8443/", $OpenInBackgroundTab)
$OpenIE.visible=$true

