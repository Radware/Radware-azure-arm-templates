## Network Interfaces
In our templates, you can choose the mode of network interfaces (NICs) you want for your Alteon.
  - **SingleIP** <br>These templates deploy a Alteon with 1 network interface (NIC), The single NIC uses both management and data plane traffic).

  - **MultiIP** <br>These templates deploy a Alteon with 2 or more NICs allows to separte between managment and data network. <br>NOTE: In Azure, the number of network interfaces an instance is allowed to have is dictated by the size of the Azure VM instance.
