
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

$adm = "admin"
$parameterFilePath = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Radware/Radware-azure-arm-templates/master/Alteon/CLI/High-Avilability/SingleIP/new-network/app/parameters.json"
$templateFilePath = "https://raw.githubusercontent.com/Radware/Radware-azure-arm-templates/master/Alteon/CLI/High-Avilability/SingleIP/new-network/app/template.json"

get-random -Minimum 100 -Maximum 9999 -OutVariable rand | out-null


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

$parameterFilePath.parameters.VMPrefixName.value = $parameterFilePath.parameters.VMPrefixName.value +$rand
###Virtual machine name###
$vmname = $(
 $VMNameselection = read-host "Virtual machine name (VA name will be prefix followed by a number 1 or 2) <"$parameterFilePath.parameters.VMPrefixName.value" is default>"
 if ($VMNameselection) {$VMNameselection} else {$parameterFilePath.parameters.VMPrefixName.value}
)


$dns1 = $vmname.ToLower() +"01"
$dns2 = $vmname.ToLower() +"02"
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
###DNSServerIP###
$DNSServerIP = $(
 $DNSServerIPselection = read-host "Specify Public DNS server  <"$parameterFilePath.parameters.DNSServerIP.value" is default>"
 if ($DNSServerIPselection) {$DNSServerIPselection} else {$parameterFilePath.parameters.DNSServerIP.value}
)

##########################

get-random -Minimum 100 -Maximum 9999 -OutVariable rand | out-null
$stgaccname = $parameterFilePath.parameters.VMPrefixName.value.ToLower() +"diag"+$rand
#######################################################

Write-Host "Please provide the following parameters for High avilability:"
Start-Sleep -Seconds 5 | out-null
$DisplayName = Read-Host "Specify DisplayName (For example: "AlteonHA")"
$HomePage =  Read-Host "Specify HomePage (For example: "https://ha.radware.com/alteon")"
$IdentifierUris = Read-Host "Specify Identifier URL (For example: "https://ha.radware.com/alteon")"
$ClientSecret = Read-Host 'Specify Client Password' -AsSecureString
Write-Host " ";


$AzureSubscriptionName = Get-AzureRmSubscription -SubscriptionName $SubscriptionName 
$AzureSubscriptionName| Select-AzureRmSubscription | out-null
$AppReg = New-AzureRmADApplication -DisplayName $DisplayName -HomePage $HomePage -IdentifierUris  $IdentifierUris -Password $ClientSecret
$ClientID = $AppReg.ApplicationId.Guid
New-AzureRmADServicePrincipal -ApplicationId $ClientID | out-null
Write-Output 'Waiting for ClientID registration'
Write-Host " ";
Start-Sleep -Seconds 40 | out-null
New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $ClientID | out-null



#####################################################################################################################




Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Write-Host " ";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace > $null;
}



#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"



# select subscription
Write-Host "Selecting subscription '$SubscriptionName'";
Write-Host " ";
Select-AzureRmSubscription -SubscriptionID $SubscriptionName > $null;

# Register RPs
$resourceProviders = @("microsoft.compute","microsoft.network","microsoft.storage") > $null;
if($resourceProviders.length) {
   # Write-Host "Registering resource providers"
   Write-Host " ";
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider) > $null;
    }
}



#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup) {
    Write-Host "Resource group '$resourceGroupName' does not exist in location '$resourceGroupLocation'. Creating now resource group: $resourceGroupName" ;
    Write-Host " ";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    Write-Host " ";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation | out-null
} else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}


Write-Host "When the deployment will be completed, Your alteons will be avilable at:";
Write-Host " ";
Write-Host " ";
Write-Host "https://$dns1.$resourceGroupLocation.cloudapp.azure.com:8443/";
Write-Host " ";
Write-Host "https://$dns2.$resourceGroupLocation.cloudapp.azure.com:8443/";
Write-Host " ";

# Start the deployment
Write-Host "Starting deployment...";
Write-Host " ";
Write-Host " ";
Write-Host " ";




$ParametersObj = @{
    storageAccountName = $stgaccname
    ClientID = "$ClientID"
    TenantID = $AzureSubscriptionName.TenantID
    dnsNameForPublicIP1 = $vmname.ToLower() +"01"
    dnsNameForPublicIP2 = $vmname.ToLower() +"02"
    DNSServerIP = "$DNSServerIP"  
    vmCount = $parameterFilePath.parameters.vmCount.value
    VMPrefixName =  "$vmname"
    vmSize =  $parameterFilePath.parameters.vmSize.value
    slbPortNumber = $parameterFilePath.parameters.slbPortNumber.value
    slbMetric = $parameterFilePath.parameters.slbMetric.value
    realsCount = $parameterFilePath.parameters.realsCount.value
    
}




New-AzureRmResourceGroupDeployment -TemplateUri $templateFilePath -TemplateParameterObject $ParametersObj -Name $resourceGroupName -adminPassword $admpw -adminUsername $parameterFilePath.parameters.adminUsername.value  -ResourceGroupName $resourceGroupName -location $resourceGroupLocation -ClientSecret $ClientSecret | out-null



Write-Host "Your alteon's will be accessible via:";
Write-Host " ";
Write-Host " ";
Write-Host "https://$dns1.$resourceGroupLocation.cloudapp.azure.com:8443/";
Write-Host " ";
Write-Host "https://$dns2.$resourceGroupLocation.cloudapp.azure.com:8443/";
Write-Host " ";
Write-Host " ";




Write-Host "When the Alteon will be accsible, it will open automaticly through your default browser";
Write-Host "";
Write-Host " ";


Start-Sleep -Seconds 2 | out-null

## Disable certificate validation
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$credential = New-Object System.Management.Automation.PSCredential( "admin", (ConvertTo-SecureString -String $adm -AsPlainText -Force) )
$counter=0
do {
    $counter++
    try{$response=Invoke-WebRequest "https://$dns1.$resourceGroupLocation.cloudapp.azure.com:8443/config" -Method PUT -Body ( ( @{ sysName=$parameterFilePath.parameters.VMPrefixName.value+"_1" } ) | ConvertTo-Json ) -Credential $credential -UseBasicParsing} catch{$response=@()}
     try{$response2=Invoke-WebRequest "https://$dns2.$resourceGroupLocation.cloudapp.azure.com:8443/config" -Method PUT -Body ( ( @{ sysName=$parameterFilePath.parameters.VMPrefixName.value+"_2" } ) | ConvertTo-Json ) -Credential $credential -UseBasicParsing} catch{$response2=@()}
    Start-Sleep -s 5
} until ( $counter -le 360 -or $response.StatusCode -eq 200 -and $response2.StatusCode -eq 200)  

If ($response.StatusCode -eq 200 -and $response2.StatusCode -eq 200 ) {
Write-Host "Opening Browser.....";

Start-Process "https://$dns1.$resourceGroupLocation.cloudapp.azure.com:8443/"
Start-Process "https://$dns2.$resourceGroupLocation.cloudapp.azure.com:8443/"

  }  Else {

  "It's seems like the Alteon is inacssible, Please verify the deployment"
  "If there is any issue with the script, Please open an issue on our GitHub page: https://github.com/Radware/Radware-azure-arm-templates/issues "

} 



