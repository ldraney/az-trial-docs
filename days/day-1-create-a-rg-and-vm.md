# Day 1 - Create a Resource Group and Virtual Machine

## Table of Contents
- [Introduction](#introduction)
- [Deploy a Resource Group and Resource](#deploy-a-resource-group-and-resource)
- [Taking Down the resources](#taking-down-the-resources)
  - [Deleting the Virtual Machine](#deleting-the-virtual-machine)
  - [Delete Associated Resources Individually](#delete-associated-resources-individually)
  - [Deleting the Entire Resource Group](#deleting-the-entire-resource-group)
  - [Verify Resource Deletion](#verify-resource-deletion)
- [Best Practices](#best-practices)
- [Keeping an Eye on Costs](#keeping-an-eye-on-costs)

## Introduction

You just made a new Azure account with $200 credits for the next month!  Exciting!  
How can you best utilize these credits?  
First, recognize that your credits are found in an automatically created subscription in your new account.  Log into your Azure dashboard, and it will be found on the default landing page for your new default directory.

Click on the Cloud Shell Button:  
![[Pasted image 20241221130618.png]]  

And run (I prefer to use the AZ CLI in bash, though you have the option for PowerShell):
```bash
az account list --output table
```
You should see a new subscription, ready and active!  Great!  
If not, activate the subscription with something like (get the actual values from your email or azure dashboard):
```bash
az account set --subscription "asdfasdfasdfasdf-asdf-431f-asdf-9999839831db"
```

## Deploy a Resource Group and Resource

Let's try deploying a resource.  In order to do that we need a resource group:
```bash
az group create --name MyResourceGroup --location eastus
```
You haven't accrued any costs up to this point.  
Azure Resource Groups are essentially logical containers used to group and manage related resources in Azure. They themselves don’t incur any cost. However, the resources within these groups—like virtual machines, storage accounts, and databases—do have associated costs. So while organizing resources into groups is free, you still pay for the individual resources you use.

Let's deploy a resource!  
WARNING: this will start using up credits and could incur real costs!  
I will include the commands to remove these resources afterwards.  Be sure to follow the entire guide!

Let's try deploying a VM:
```bash
az vm create \
  --resource-group MyResourceGroup \
  --name MyVM \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --generate-ssh-keys
```
You should see something like:
```bash
/usr/lib64/az/lib/python3.9/site-packages/paramiko/pkey.py:100: CryptographyDeprecationWarning: ...
SSH key files '/home/lucas/.ssh/id_rsa' and '/home/lucas/.ssh/id_rsa.pub' have been generated under ~/.ssh to allow SSH access to the VM. If using machines without permanent storage, back up your keys to a safe location.
 - Running ...
```
and then the details of the VM that was created!  Here is an example with fake output:
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
Congrats!  It worked!  You are now running a VM in the cloud!

<br>  

## Taking Down the resources

### Deleting the Virtual Machine

Let's take down this VM so we aren't losing our valuable credits!

To delete the specific VM without affecting other resources:
```bash
az vm delete --resource-group MyResourceGroup --name MyVM --yes
```
This deletes the VM but may leave behind resources like disks, NICs, or public IP addresses. 

However, note that we still have existing resources!
```bash
az resource list --resource-group MyResourceGroup --output table
```
The output is:
```markdown
Name                                         ResourceGroup    Location    Type                                     Status
-------------------------------------------  ---------------  ----------  ---------------------------------------  --------
MyVMPublicIP                                 MyResourceGroup  eastus      Microsoft.Network/publicIPAddresses
MyVMNSG                                      MyResourceGroup  eastus      Microsoft.Network/networkSecurityGroups
MyVMVNET                                     MyResourceGroup  eastus      Microsoft.Network/virtualNetworks
MyVMVMNic                                    MyResourceGroup  eastus      Microsoft.Network/networkInterfaces
MyVM_disk1_a34baab031fb4c3b8563b3994d153fbc  MYRESOURCEGROUP  eastus      Microsoft.Compute/disks
```
We can delete these individually or via resource group.  Let's do both for our own learning.

### **Delete Associated Resources Individually**:  
   If you want to delete resources selectively instead of removing the entire resource group, follow these steps for each resource listed in the output:  
   (The following commands names are based on the output I received in the previous step.)

   1. **Delete the Managed Disk**:
      ```bash
      az disk delete --resource-group MyResourceGroup --name MyVM_disk1_a34baab031fb4c3b8563b3994d153fbc --yes --no-wait
      ```

   2. **Delete the Network Interface**:
      ```bash
      az network nic delete --resource-group MyResourceGroup --name MyVMVMNic
      ```

   3. **Delete the Public IP Address**:
      ```bash
      az network public-ip delete --resource-group MyResourceGroup --name MyVMPublicIP
      ```

   4. **Delete the Network Security Group (NSG)**:
      ```bash
      az network nsg delete --resource-group MyResourceGroup --name MyVMNSG
      ```

   5. **Delete the Virtual Network (VNET)**:
      ```bash
      az network vnet delete --resource-group MyResourceGroup --name MyVMVNET
      ```

#### Notes:

- **Order of Deletion**: Azure dependencies require resources like NICs to be deleted before their dependent resources (e.g., NSGs or VNETs). Ensure you follow the order above.  
- **Cleanup Verification**: After executing the commands, check if any resources remain:
  ```bash
  az resource list --resource-group MyResourceGroup --output table
  ```

#### Deleting the Entire Resource Group

If you don’t need the resource group or want to save time, or the resource group was created solely for testing, the simplest method is to delete the entire group. 
This removes all associated resources:
```bash
az group delete --name MyResourceGroup --yes --no-wait
```
- `--yes`: Confirms the deletion without prompting.  
- `--no-wait`: Allows the command to execute asynchronously.

### Verify Resource Deletion

After deletion, verify that no resources are left:
```bash
az resource list --resource-group MyResourceGroup --output table
```
Output should be:
```bash
(ResourceGroupNotFound) Resource group 'MyResourceGroup' could not be found.
Code: ResourceGroupNotFound
Message: Resource group 'MyResourceGroup' could not be found.
```

<br>

## Best Practices

- Always double-check the resources in the group before deletion to ensure you aren't deleting something unintentionally.  
- Consider using `--debug` for a detailed execution log if you encounter any issues.

<br>

## Keeping an Eye on Costs

Over the next 30 days, make it a habit to check your usage regularly. Use the **Cost Management + Billing** section in the Azure portal to monitor your credit balance and track which resources are consuming your credits. A quick check every couple of days can help you catch unexpected costs early and adjust as needed. 

We’ll cover setting up alerts and other optimizations another day—focus on getting comfortable with tracking your usage for now.
