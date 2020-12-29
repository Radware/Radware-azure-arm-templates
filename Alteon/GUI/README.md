[![Issues](https://img.shields.io/github/issues/Radware/Radware-azure-arm-templates)](https://github.com/radware/Radware-azure-arm-templates/issues)
[![Commit](https://img.shields.io/github/last-commit/Radware/Radware-azure-arm-templates)]()

## Template type

- **Standalone** <br> Standalone templates deploy an individual Alteon VA. <br> Standalone deployments primarily used for testing or development. They also used for auto-scaling deployments.


- **High-Avilability** <br> High-Availability templates deploy Alteon pair in HA mode. <br> Failover clusters primarily used to replicate traditional Active/Standby Alteon deployments <br> Unlike on-premise failover with network protocol like Gratuitos ARP failover, Azure using API calls made from Alteon to Azure to switch network nics between Active and Standby Alteon. <br> Different from on-premise high-availability, there is no use in floating IP.

