$AzureAppReg = Invoke-WebRequest https://raw.githubusercontent.com/Radware/Azure-App-registration/master/app/AppReg.ps1
Invoke-Expression $($AzureAppReg.Content)
Remove-Variable -Name AzureAppReg;
