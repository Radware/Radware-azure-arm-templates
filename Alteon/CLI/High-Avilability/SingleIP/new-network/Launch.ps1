$alteonsingledeployment = Invoke-WebRequest https://raw.githubusercontent.com/Radware/Radware-azure-arm-templates/master/Alteon/CLI/Standalone/SingleIP/new-network/app/AlteonPS.ps1
Invoke-Expression $($alteonsingledeployment.Content)
Remove-Variable -Name alteonsingledeployment;