$alteonsingledeployment = Invoke-WebRequest https://raw.githubusercontent.com/Radware/Alteon-Azure-powershell-deployment/master/app/AlteonPS.ps1
Invoke-Expression $($alteonsingledeployment.Content)
Remove-Variable -Name alteonsingledeployment;
