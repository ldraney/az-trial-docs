# Day 1 - Create a Resource Group and Virtual Machine.md

You just made a new Azure account with $200 credits for the next month! Exciting!  
How can you best utilize these credits for learning and setting up your business?  
Today, we'll just verify everythign is ready for you to start deploying some infrastructure.  
Tomorrow, we'll deploy some Bicep code for a minimal full stack infrastructure for a startup application.  

### Table of Contents

1. [Azure Free Trial Day 1 - Create a Resource Group and Virtual Machine](#azure-free-trial-day-1---create-a-resource-group-and-virtual-machine)  
   - [Introduction](#introduction)  
   - [Verify Subscription](#verify-subscription)  
   - [Activate Subscription](#activate-subscription)  

2. [Deploy a Resource Group and Resource](#deploy-a-resource-group-and-resource)  
   - [What Are Resource Groups?](#what-are-resource-groups)  
   - [Creating a Resource Group](#creating-a-resource-group)  

3. [Deploying a Virtual Machine (VM)](#deploying-a-virtual-machine-vm)  
   - [Steps to Create a Virtual Machine](#steps-to-create-a-virtual-machine)  
   - [VM Creation Output Example](#vm-creation-output-example)  

4. [Taking Down the Resources](#taking-down-the-resources)  
   - [Deleting the Virtual Machine](#deleting-the-virtual-machine)  
   - [Cleaning Up Resources](#cleaning-up-resources)  

5. [Keeping an Eye on Costs](#keeping-an-eye-on-costs)  
   - [Monitoring Credit Usage](#monitoring-credit-usage)  

6. [Preparing for Day 2](#preparing-for-day-2)  
   - [Day 2 Preview](#day-2-preview)  

# Azure Free Trial Day 1 - Create a Resource Group and Virtual Machine

## Introduction

You just made a new Azure account with $200 credits for the next month! Exciting!  
How can you best utilize these credits?

First, recognize that your credits are found in an automatically created subscription in your new account. Log into your Azure dashboard, and it will be found on the default landing page for your new default directory.

## Verify Subscription

Click on the Cloud Shell Button:  
![image](https://github.com/user-attachments/assets/19021b17-d5f0-44ae-bb7a-2119758323bd)

And run the following command (I prefer to use the AZ CLI in Bash, though you have the option for PowerShell):

```bash
az account list --output table
```

You should see a new subscription, ready and active! Great!

## Activate Subscription

If not, activate the subscription with something like this (get the actual values from your email or Azure dashboard):

```bash
az account set --subscription "asdfasdfasdfasdf-asdf-431f-asdf-9999839831db"
```

---

## Deploy a Resource Group and Resource

### What Are Resource Groups?

Azure Resource Groups are essentially logical containers used to group and manage related resources in Azure. They themselves don’t incur any cost. However, the resources within these groups—like virtual machines, storage accounts, and databases—do have associated costs. So while organizing resources into groups is free, you still pay for the individual resources you use.

### Creating a Resource Group

Let’s try deploying a resource. In order to do that, we need a resource group:

```bash
az group create --name MyResourceGroup --location eastus
```

At this point, you haven’t accrued any costs.

---

## Deploying a Virtual Machine (VM)

### Steps to Create a Virtual Machine

Let’s deploy a resource!  
**WARNING:** This will start using up credits and could incur real costs!  
I will include the commands to remove these resources afterward. Be sure to follow the entire guide!

Run the following command to create a VM:

```bash
az vm create \
  --resource-group MyResourceGroup \
  --name MyVM \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --generate-ssh-keys
```

### VM Creation Output Example

You should see something like this:

```bash
/usr/lib64/az/lib/python3.9/site-packages/paramiko/pkey.py:100: CryptographyDeprecationWarning: TripleDES has been moved to cryptography.hazmat.decrepit.ciphers.algorithms.TripleDES and will be removed from this module in 48.0.0.
  "cipher": algorithms.TripleDES,
/usr/lib64/az/lib/python3.9/site-packages/paramiko/transport.py:259: CryptographyDeprecationWarning: TripleDES has been moved to cryptography.hazmat.decrepit.ciphers.algorithms.TripleDES and will be removed from this module in 48.0.0.
  "class": algorithms.TripleDES,
SSH key files '/home/lucas/.ssh/id_rsa' and '/home/lucas/.ssh/id_rsa.pub' have been generated under ~/.ssh to allow SSH access to the VM. If using machines without permanent storage, back up your keys to a safe location.
 - Running ...
```

Then, you’ll see the details of the VM that was created. Here is an example with fake output:

```json
{
  "fqdns": "myvm.example.com",
  "id": "/subscriptions/12345678-90ab-cdef-1234-567890abcdef/resourceGroups/TestResourceGroup/providers/Microsoft.Compute/virtualMachines/TestVM",
  "location": "westus",
  "macAddress": "AA-BB-CC-DD-EE-FF",
  "powerState": "VM deallocated",
  "privateIpAddress": "192.168.1.10",
  "publicIpAddress": "203.0.113.24",
  "resourceGroup": "TestResourceGroup",
  "zones": "1"
}
```

Congrats! It worked! You are now running a VM in the cloud!

---

## Taking Down the Resources

### Deleting the Virtual Machine

Let’s take down this VM so we aren’t losing our valuable credits!

To delete the specific VM without affecting other resources:

```bash
az vm delete --resource-group MyResourceGroup --name MyVM --yes
```

### Cleaning Up Resources

This deletes the VM but may leave behind resources like disks, NICs, or public IP addresses. To avoid leftover costs:

1. **List Resources in the Resource Group**:

   ```bash
   az resource list --resource-group MyResourceGroup --output table
   ```

   The output will look like this:

   ```plaintext
   Name                                         ResourceGroup    Location    Type                                     Status
   -------------------------------------------  ---------------  ----------  ---------------------------------------  --------
   MyVMPublicIP                                 MyResourceGroup  eastus      Microsoft.Network/publicIPAddresses
   MyVMNSG                                      MyResourceGroup  eastus      Microsoft.Network/networkSecurityGroups
   MyVMVNET                                     MyResourceGroup  eastus      Microsoft.Network/virtualNetworks
   MyVMVMNic                                    MyResourceGroup  eastus      Microsoft.Network/networkInterfaces
   MyVM_disk1_a34baab031fb4c3b8563b3994d153fbc  MYRESOURCEGROUP  eastus      Microsoft.Compute/disks
   ```

---

## Keeping an Eye on Costs

### Monitoring Credit Usage

Over the next 30 days, make it a habit to check your usage regularly. Use the **Cost Management + Billing** section in the Azure portal to monitor your credit balance and track which resources are consuming your credits. A quick check every couple of days can help you catch unexpected costs early and adjust as needed.

---

## Preparing for Day 2

### Day 2 Preview

Tomorrow we will be building the foundational architecture for a full-stack application on Azure, starting with setting up a GitHub repository and integrating it with Azure for version control and deployment pipelines. From there, we’ll dive into Azure Bicep to define infrastructure-as-code for a startup’s architecture, aligning with Azure’s Core Startup Stack principles. This will include deploying the Bicep templates via GitHub Actions and testing processes for tearing down infrastructure, paving the way for a robust and scalable application environment.
