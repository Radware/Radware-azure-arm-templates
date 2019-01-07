#Uncomment the following line if Azure cmdlet is not installed:
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted
#Install-Module -Name AzureRM -AllowClobber

#Uncomment the following line if this script run from windows Power-Shell client:
#Connect-AzureRmAccount




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

    $SubSelection = Read-Host "Please make a selection"

    if ($SubSelection -eq 'Q') { Return } Else { $Menu.$SubSelection }

}
$UserSelection = Show-Menu -Title 'Subscription Choose'
Write-Host "Choosen subscription: $UserSelection

"
}




$SubscriptionName = $UserSelection
$DisplayName = Read-Host "Please specify DisplayName (For example: "AlteonHA")"
$HomePage =  Read-Host "Please specify HomePage (For example: "https://ha.radware.com/alteon")"
$IdentifierUris = Read-Host "Please specify Identifier URL (For example: "https://ha.radware.com/alteon")"
$ClientSecret = Read-Host 'Please specify Client Password (It will be necesary later)' -AsSecureString


$AzureSubscriptionName = Get-AzureRmSubscription -SubscriptionName $SubscriptionName 
$AzureSubscriptionName| Select-AzureRmSubscription | out-null
$AppReg = New-AzureRmADApplication -DisplayName $DisplayName -HomePage $HomePage -IdentifierUris  $IdentifierUris -Password $ClientSecret
$ClientID = $AppReg.ApplicationId.Guid
New-AzureRmADServicePrincipal -ApplicationId $ClientID 
Write-Output 'Waiting for ClientID registration'
Start-Sleep -Seconds 30 | out-null
New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $ClientID
Write-Output @{ "Client ID" = $ClientID; "Tenant ID" = $AzureSubscriptionName.TenantID; "Subscription Name" = $AzureSubscriptionName.Name; "AppID" = $AppReg.DisplayName; }
Write-Output 'Please save those parmateres '

Read-Host "Press Q to close the window"


