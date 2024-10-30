Deploying LEMP using Azure Verified Modules
Deploying LEMP using Azure Verified Modules that are published in the Public Bicep Registry (br/public).

Architecture
Image of LEMP architecture

Core Resource Group
Containing:

Azure Virtual Network: Two subnets, one for workloads and one for Azure Bastion. The subnets are protected with Network Security Groups.
Private DNS Zone: For Azure Key Vault and integrated into the Virtual Network.
Public IP and Azure Bastion Hosts: Deployed into the Virtual Network subnet for Azure Bastion.
Notes: Considering adopting ALZ and placing the Azure Bastion Host in the Hub.

Workload Resource Group
Containing:

Azure Key Vault: Public network access disabled, uses the Azure RBAC authorization model. It also has a Private Endpoint deployed into the Virtual Network workload subnet, and is linked to the Private DNS Zone for Azure Key Vault.
Azure Virtual Machine: Deployed into the Virtual Network workload subnet, with a User Assigned Managed Identity that has its "owned custom" Role at the Azure Key Vault Scope.
Deployment
Average Deployment time: 20-30 minutes

Steps:

Open a Visual Studio Code session.
Clone the repository.
Open a VS Code session in the folder for the cloned repo:
Save the above cont