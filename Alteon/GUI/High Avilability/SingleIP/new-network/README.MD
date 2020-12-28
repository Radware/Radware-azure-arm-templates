# Alteon powershell deployment

## Table Of Contents ###
- [Description](#description )
- [How To Use](#how-to-use )
  * [Required modules](#Required-modules)
  * [Using Launch file](#Using-Launch-file)
- [Currently Supported](#currently-supported)
- [Planed In The Future](#planed-in-the-future)

## Description ##
The following script is used to deploy alteon VM on azure with Microsoft Powershell script.<br>
The script was tested on both windows Powershell client and Azure shell.<br>
Supported deployment: Single IP.<br>


## How To Use ##
### Required modules ###
In order to use the script make sure you have installed AzureRM cmdlet, and ExuctionPolicy set to "Unrestricted".


### Using Launch file ###
Just run the launch file ("Launch.ps1") and the script will be loaded "Launch.ps1",<br>
This file will pull dynamicly the neceasry files for deployment.

## Planed In The Future ##
* Multiple IP.
* HA Deployment.
* Autoscale Deployment.
