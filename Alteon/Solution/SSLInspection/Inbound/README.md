# SSL Inspect Solution Template

## Table Of Contents ###
- [Description](#description )
- [Alteon Initial Configuration](#Alteon-Initial-Configuration)
  * [VIP-1](#VIP-1)
  * [VIP-2](#VIP-2)

## Description
This template will deploy an Alteon ScaleSet into an existing VNET ready for performing SSL decryption and stearing to another security device.
Alteon has the ability to detect members of a scaleset, thus both the BackEnd servers and the Security devices can be configured manually or fetched automatically by simply pointed to a scaleset name.

**Alteon - Inound SSL Inspection**
    <br><ahref= "https%3A%2F%2Fportal.azure.com%2F%23blade%2FMicrosoft_Azure_Compute%2FCreateMultiVmWizardBlade%2Finternal_bladeCallId%2Fanything%2Finternal_bladeCallerParams%2F%7B%22initialData%22%3A%7B%7D%2C%22providerConfig%22%3A%7B%22createUiDefinition%22%3A%22https%3A%2F%2Fraw.githubusercontent.com%2FRadware%2FRadware-azure-arm-templates%2Fmaster%2FAlteon%2FSolution%2FSSLInspection%2FInbound%2FcreateUiDefinition_cluster.json%22%7D%7D&data=02%7C01%7COrZ%40radware.com%7Cb1bfb00e5654463d98dc08d68ffb9661%7C6ae4e000b5d04f48a766402d46119b76%7C0%7C0%7C636854708057934150&sdata=r9VEv4nmDfiSCh57Pu4ayWw5O6Itm7dRxVSBmc2XzEw%3D&reserved=0">  <img src="http://azuredeploy.net/deploybutton.png"/></a><br>
       
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
