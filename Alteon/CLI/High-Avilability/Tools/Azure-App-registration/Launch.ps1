$AzureAppReg = Invoke-WebRequest https://raw.githubusercontent.com/Radware/Radware-azure-arm-templates/master/Alteon/CLI/High-Avilability/Tools/Azure-App-registration/app/AppReg.ps1
Invoke-Expression $($AzureAppReg.Content)
Remove-Variable -Name AzureAppReg;
