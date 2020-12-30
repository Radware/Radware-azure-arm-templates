## Network Type

[![Issues](https://img.shields.io/github/issues/Radware/Radware-azure-arm-templates)](https://github.com/radware/Radware-azure-arm-templates/issues)
[![Commit](https://img.shields.io/github/last-commit/Radware/Radware-azure-arm-templates)]()

For each of the standalone templates, you must choose the type of network into which you want to deploy the Alteon VA. 

  - **New Network** <br>This solution deploys into a new cloud network, this means that all of the cloud networking infrastructure required will be created along with the deployment. 

  - **Existing Netwrok** <br> These templates deploy into an existing  network.  This means that all of the cloud networking infrastructure must be available prior to launching the template. By default, the template will create and attach Public IP Address(es) to the Alteon interface(s).
