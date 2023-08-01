# Cloud Endpoint
# Azure Virtual Desktop deployment with Terraform
This repository contains Terraform code to deploy a complete Azure Virtual Desktop (AVD) platform. The infrastructure is provisioned with the following components through an AVD module:

- **Workspace**: Sets up an AVD workspace, providing the foundation for managing virtual desktops and applications.

- **Desktop Application Group**: Creates an application group within the workspace, allowing you to publish applications to users. AVD User group is automatically assigned the proper roles to immediately access the Cloud Endpoint.

- **Host Pool**: Deploys a host pool, which consists of one or more virtual machines running Windows 11 Multisession 22H2. These virtual machines serve as the desktops for end-users.

- **Identity & Management**: Sessions Hosts are Microsoft Entra Id Joined and automatically registered in Microsoft Intune. Session hosts also have the Azure Monitor Agent (AMA) extension installed for monitoring purposes.

- **Dedicated Virtual Network**: Creates a dedicated virtual network (VNET) for the AVD environment, ensuring network isolation and security.

- **VNET Peering**: Provides an option to peer the dedicated VNET with an existing hub, enabling connectivity with other resources in your network.

- **Storage**: Creates an Azure File Share to host FSlogix user profiles with the proper RBAC permissions

- **KeyVault**: Sets up a KeyVault to securely store and manage the local administrator password for the AVD virtual machines.

- **Log Analytics Workspace**: Creates a Log Analytics workspace allowing you to collect and analyze logs from your AVD environment.

- **Compute Gallery**: Creates a Compute Gallery with a Windows 11 multisession 365 Apps image definition

## Architecture

![Alt text]

## Prerequisites for interactive deployment
To use this Terraform code and deploy the AVD platform, ensure you have the following:

Azure subscription: Create an Azure subscription if you don't have one already.
Terraform: Install Terraform on your local machine. Refer to the official Terraform documentation for installation instructions.
Azure CLI: Install the Azure CLI on your local machine. You can find installation instructions in the Azure CLI documentation.

## Getting Started
To deploy the AVD platform in an interactive way, follow these steps:

Clone this repository to your local machine.
Open a terminal or command prompt and navigate to the repository's root directory.

- Initialize Terraform by running the following command:
**_terraform init_**

- Authenticate to Azure by running the following command and following the prompts:
**_az login_**

Modify the variables files to provide the required variables, such as your Azure AVD Users group, resource group, and other deployment-specific configurations.
Review and customize the desired infrastructure configuration in the Terraform code, located in the .tf files.

- Validate the Terraform configuration by running the following command:
**_terraform validate_**

- Preview the infrastructure changes that Terraform will apply by running the following command:
**_terraform plan_**

- Deploy the AVD platform by running the following command:
**_terraform apply_**

Review the planned changes and type yes when prompted to confirm the deployment.
Sit back and relax while Terraform provisions the AVD platform. The deployment may take several minutes.

After the deployment completes successfully, Terraform will display the output variables that provide important information about the deployed resources.

- To remove the AVD platform and associated resources, you can use Terraform to destroy the infrastructure. Run the following command:
**_terraform destroy_**

Review the planned changes and type yes when prompted to confirm the destruction.

Note: Be cautious when using the terraform destroy command as it will delete all the resources created during the deployment.

## Prerequisites for CI/CD deployment
- Create an Azure Service Principal:<br>
**az ad sp create-for-rbac --name "TerraformSPN" --role Contributor --scopes /subscriptions/ --sdk-auth**

- Create an Azure Storage Account to store Terraform tfstate file:<br>
**az group create -g RG-TFSTO-DEV -l northeurope**<br>
**az storage account create -n azstotf2021 -g RG-TFSTO-DEV -l northeurope --sku Standard_LRS**<br>
**az storage container create -n terraform-state --account-name azstotf2021**

- Create GitHub Secrets to securely pass SPN secrets and Azure information:<br>
**ARM_CLIENT_ID: ${{secrets.SPN_ID}}**<br>
**ARM_CLIENT_SECRET: ${{secrets.SPN_PWD}}**<br>
**ARM_SUBSCRIPTION_ID: ${{secrets.AZURE_SUBSCRIPTIONID}}**<br>
**ARM_TENANT_ID: ${{secrets.AZURE_TENANTID}}**

## Contributing
Contributions to this repository are welcome! If you find any issues or have suggestions for improvements, please submit an issue or a pull request.

## License
This project is licensed under the MIT License. Feel free to use the code as a reference or modify it to meet your specific requirements.

## Disclaimer
This repository is provided as-is and is not officially supported by Azure or Microsoft. Use the code and the deployment at your own risk.
