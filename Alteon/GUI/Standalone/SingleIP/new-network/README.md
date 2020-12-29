# Deploying the Alteon VA in Azure - Single IP

[![Issues](https://img.shields.io/github/issues/Radware/Radware-azure-arm-templates)](https://github.com/radware/Radware-azure-arm-templates/issues)
[![Commit](https://img.shields.io/github/last-commit/Radware/Radware-azure-arm-templates)]()


## Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Configuration Notes](#iconfiguration-notes)
- [Deployment](#Deployment)

## Introduction

This solution uses an ARM template to launch a single NIC deployment of a cloud-focused Alteon VA in Microsoft Azure. Traffic flows from the Alteon VA to the application servers. This is the standard Cloud design where the  Alteon VA instance is running with a single interface, where both management and data plane traffic is processed.  This is a traditional model in the cloud where the deployment is considered one-armed.

Alteon VA for Microsoft Azure cloud allows running your enterprise applications while tapping into
Microsoft Azure computing resources and providing a common application delivery platform for your
applications. Leveraging the common Alteon operating system across Microsoft Azure cloud and the
enterprise datacenter, enables faster application development cycles and improved economies for
disaster recovery and seasonal application capacity scalability requirements. The figures below show
a reference Alteon VA deployment on Microsoft Azure cloud in a single and in a multiple IP address
mode.

For information on getting started using Alteon on Azure, see [Alteon in Azure](https://support.radware.com/app/answers/answer_view/a_id/20942/related/1).

**Networking  Type:** This solution deploys into a new networking, which is created along with the solution.


## Prerequisites

- **Important**: When you configure the admin User/Password for the Alteon it will used for maint mode, Alteon User/Passwrod will remain default. 

- Knowledge of Microsoft Azure and deploying VMs on the Microsoft Azure cloud.
- Knowledge of Alteon Application Switch operating system.
- Since you are deploying the BYOL template, you must have a valid Alteon license.

## Configuration Notes

### Web Interface

Alteon VA, when running on Microsoft Azure, is configured to have its management controlled
through the data path. This is due to the fact that any instance on Microsoft Azure is provided with a
single IP address per network interface.
In order to enable load-balancing HTTPS traffic and management access, the HTTPS port for
management access is changed to 8443.
To access the Alteon web interface, open your browser and enter the Alteon VA instance IP address
with port 8443.
For example, if the Alteon VM IP address is 1.1.1.1, enter https://1.1.1.1:8443
To log in, enter the default username and password: admin, admin

Note: If you do not intend to load balance HTTPS traffic, you can change the HTTPS port for
management purposes to the standard HTTPS port 443 through the Web interface at:
>Configuration>System>Management Access>Management Protocols
or through the CLI command: /c/sys/access/https/port.

### CLI Interface

To connect to Alteon VA through the command line interface (CLI), connect to Alteon VA port 22
using any terminal emulator supporting SSH (such as PUTTY).
Enter the default username and password: admin, admin
The CLI main menu is displayed.
It is strongly recommend you change the password on your first login.

### Cloud Init

You can deploy a pre-configured Alteon VA using the cloud-init feature.
Refer to the Alteon VA Installation Guide for details of the Alteon VA cloud-init support


## Deployment

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FRadware%2FRadware-azure-arm-templates%2Fmaster%2FAlteon%2FGUI%2FStandalone%2FSingleIP%2Fnew-network%2Fdeploy.template.json">  <img src="https://aka.ms/deploytoazurebutton"/></a><br>
