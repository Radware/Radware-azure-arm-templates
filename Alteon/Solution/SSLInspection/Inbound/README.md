# SSL Inspect Solution Template

## Table Of Contents ###
- [Description](#description )
- [Alteon Initial Configuration](#Alteon-Initial-Configuration)
  * [VIP-1](#VIP-1)
  * [VIP-2](#VIP-2)

## Description
This template will deploy an Alteon ScaleSet into an existing VNET ready for performing SSL decryption and stearing to another security device.
Alteon has the ability to detect members of a scaleset, thus both the BackEnd servers and the Security devices can be configured manually or fetched automatically by simply pointed to a scaleset name.

       
## Alteon Initial Configuration
Each Alteon will poweron with the following configuration
### VIP-1
- This VIP is expected to recieve encrypted traffic from a public client
- <b>OPTIONAL : </b> contain a bypass list (based on SSL SNI header), when matched the traffic is sent to the backend server diractly 
- Decrypt the SSL 
- Send the decrypted traffic to a security device

### VIP-2
- This VIP is expected to recieve decrypted traffic from within the VNET (back from the security device)
- <b>OPTIONAL : </b> encrypt the traffic 
- Send the traffic to the backend servers
