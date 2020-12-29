## Single/Multi IP

[![Issues](https://img.shields.io/github/issues/Radware/Radware-azure-arm-templates)](https://github.com/radware/Radware-azure-arm-templates/issues)
[![Commit](https://img.shields.io/github/last-commit/Radware/Radware-azure-arm-templates)]()

In many of our templates, You can choose between single IP vs. Multi IP.
Alteon VA running on the Azure Cloud runs by default in single IP address mode.<br> This is
very useful when using Alteon to manage a single service.
When there is a use case where there more than one application using the same service port, Multi IP is needed


  - **Single IP** <br> When running on Microsoft Azure, is configured to have its management
controlled through the data path. This is because any instance on Microsoft Azure is
provided with a single IP address per network interface. To enable load-balancing
HTTPS traffic and management access, the HTTPS port for management access is
changed to 8443. To access the Alteon Web interface, open your browser and enter the
Alteon VA instance IP address with port 8443. For example, if the Alteon VM IP address
is 1.1.1.1, enter https://1.1.1.1:8443

 - **Multi IP** <br> These templates deploy an Alteon VA with N NICs for use in environments with a separate management network. 

