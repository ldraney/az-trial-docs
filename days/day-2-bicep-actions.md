# Day 2 - Bicep Filetree and GitHub Actions

## Introduction

In my previous post, I forgot before we deploy a minimal architecture, we need to set up our GitHub Actions!  Apologies!  

So, for **Day 2**, we’re integrating GitHub and Azure to automate deployments using GitHub Actions (GAs). The goal is to keep our secret credentials secure by storing them once (in GitHub) and using them in our workflows, instead of storing them locally on multiple machines. This ensures a more robust and secure CI/CD process for our new startup infrastructure.

### Table of Contents

1. [Azure RBAC Setup for GitHub Actions](#azure-rbac-setup-for-github-actions)  
   - [Creating a Service Principal](#creating-a-service-principal)  
   - [Assigning the Role](#assigning-the-role)  
   - [Storing Credentials in GitHub Secrets](#storing-credentials-in-github-secrets)

2. [Testing Azure Connectivity with a Simple Workflow](#testing-azure-connectivity-with-a-simple-workflow)  
   - [Creating the GitHub Actions Workflow](#creating-the-github-actions-workflow)  
   - [Confirming Connectivity](#confirming-connectivity)

3. Deploy a resource group

4. Set up modules directory

5. [Tearing Down the Resource Group](#tearing-down-the-resource-group)  
   - [Delete the Entire Resource Group](#delete-the-entire-resource-group)  
   - [Removing Individual Modules (Optional)](#removing-individual-resources-optional)

6. Preparing for tomorrow - Shared responsibility model and being a one-man startup - first we deploy app service with a nginx container, then we deploy minimum architecture?  
Goal for next day is to deploy the easiest thing possible, ideally a container, how about linux-server obsidian container that can now have a public URL?  


---

## Azure RBAC Setup for GitHub Actions

### Creating a Service Principal

To allow GitHub Actions to interact with your Azure subscription, you’ll need a **Service Principal** (an identity used by apps or services to access Azure). 

1. Open your **Azure Cloud Shell** or local terminal configured with the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli).
2. Run:

   ```bash
   az ad sp create-for-rbac \
     --name "github-actions-sp" \
     --role contributor \
     --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID> \
     --sdk-auth
   ```

   **Important**: Replace `<YOUR_SUBSCRIPTION_ID>` with the ID of your subscription (found in the Day 1 steps with `az account list --output table`).

3. You’ll get a JSON output like this:

   ```json
   {
     "clientId": "<GUID>",
     "clientSecret": "<SECRET_VALUE>",
     "subscriptionId": "<GUID>",
     "tenantId": "<GUID>",
     "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
     "resourceManagerEndpointUrl": "https://management.azure.com/",
     "activeDirectoryGraphResourceId": "https://graph.windows.net/",
     "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
     "galleryEndpointUrl": "https://gallery.azure.com/",
     "managementEndpointUrl": "https://management.core.windows.net/"
   }
   ```

### Assigning the Role

If you used the `--role contributor` flag above, your Service Principal has rights to create and manage resources. If you need more/less access, you could use roles like **Reader**, **Owner**, or custom roles. Adjust as needed.

### Storing Credentials in GitHub Secrets

1. Go to your **GitHub Repository** settings.  
2. Click on **Secrets and variables** > **Actions**.  
3. Create a **New repository secret** named `AZURE_CREDENTIALS`.  
4. Copy the **entire JSON output** from the `az ad sp create-for-rbac` command and paste it into the **Value** field.  
5. Save it.

Great! Now GitHub has stored your Azure credentials securely. We’ll reference them in our workflows as `secrets.AZURE_CREDENTIALS`.

---

## Testing Azure Connectivity with a Simple Workflow

Before we start deploying fancy resources, let’s verify that GitHub Actions can indeed connect to Azure with our new credentials.

### Creating the GitHub Actions Workflow

1. In your repository, navigate to **Actions**.
2. Click **New workflow** (or **Set up a workflow yourself**).
3. Create a file named `.github/workflows/test-azure-connection.yml` (for example).
4. Add the following content:

   ```yaml
   name: Test Azure Connection

   on: [workflow_dispatch]

   jobs:
     test-connection:
       runs-on: ubuntu-latest
       steps:
         - name: Checkout
           uses: actions/checkout@v3

         - name: Azure Login
           uses: azure/login@v1
           with:
             creds: ${{ secrets.AZURE_CREDENTIALS }}

         - name: Show Subscriptions
           run: |
             az account show
   ```

### Confirming Connectivity

1. Commit and push your workflow file to the repository.  
2. Go to the **Actions** tab, select **Test Azure Connection**, and run the workflow manually (click **Run workflow**).  
3. Watch the logs. If everything is set up properly, you’ll see an Azure subscription ID in the output. Congratulations!

---
## Why Bicep?

To understand the value of infrastructure as code (IaC), Bicep, and whether Bicep is the right choice for your IaC, please go to: https://learn.microsoft.com/en-us/training/paths/fundamentals-bicep/

As a principal, never make something more complicated than it needs to be.  At this point, Bicep will help us build out a general but fairly comprehensive infrastructure for our application.  Bicep has nice features such as diagrams in VS Code and managing the sequence and dependency of resources, so we can focus on the configurations we need rather than ensuring they are set up correctly.  

If we need to get more specific with configurations, we can consider ARM templates or other forms of IaC.  

Why Bicep or ARM over Terraform or other solutions?  All solutions will need to use the Azure Resource Manager's API to control Azure infrastructure, so preference based on familiarity is appropriate here.  I like to stick within the Microsoft ecosystem unless the value of an external option obviously outweighs Microsoft's integrated systems.  

## Github Workflow to Deploy a RG and VM with Bicep

Now that we know the connection works, let's make a new workflow that allows us deploy resources:

Let's make a workflow file, say `.github/workflows/deploy-bicep-vm.yml`, and enter the following:

```yaml
name: Deploy Bicep VM with Resource Group

on: [workflow_dispatch]

jobs:
  deploy-bicep:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy Resources via Bicep
        run: |
          az deployment group create \
            --resource-group MyResourceGroup \
            --template-file ./main.bicep \
            --parameters ./main.parameters.json
```

After pushing and running this workflow, you should see a resource group with your new VM in the Azure portal; however, we are not yet ready for that. 

There is one more useful workflow for us to create that allows us to view the ARM templates our Bicep will create.  To understand what I'm talking about, it may be worthwhile to play with Bicep and see the ARM templates it generates, go to https://aka.ms/bicepdemo.  

Here is the [[GA Workflow for Building Bicep]].  This workflow will allow us to validate and check the templates that Bicep sends to Azure Resource Manager.  This is useful as our app gets more complex and we need to check or adjust configurations. 

### Deploying a VM with Bicep

We’re going to create a **Bicep** file (`main.bicep`) that defines a VM resource. This is similar to Day 1’s approach, but in code form.

> **Sample `main.bicep`:**  

```bicep
@description('Name of the Resource Group.')
param resourceGroupName string

@description('Location for all resources.')
param location string

@description('Name of the Virtual Machine.')
param vmName string

@description('Admin username for the Virtual Machine.')
param adminUsername string

@secure()
@description('Admin password for the Virtual Machine.')
param adminPassword string

resource myResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

resource myVM 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: myResourceGroup.location
  dependsOn: [
    myResourceGroup
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'myVMNic')
        }
      ]
    }
  }
}
```

**Key Features**
- myResourceGroup: Declares the resource group.
- Dependency Management: Bicep ensures myResourceGroup is created before myVM because of the dependsOn property (implicitly handled when referencing myResourceGroup.location but explicitly added here for clarity).

### Parameters file
Here's the matching main.parameters.json:
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "resourceGroupName": {
      "value": "MyResourceGroup"
    },
    "location": {
      "value": "eastus"
    },
    "vmName": {
      "value": "MyBicepVM"
    },
    "adminUsername": {
      "value": "myAdminUser"
    },
    "adminPassword": {
      "value": "ReplaceWithSecurePassword123!"
    }
  }
}
```


After pushing and running this workflow, you should see a resource group with your new VM in the Azure portal!

### **How It Works**
1. **Resource Group Managed by Bicep**:
   - The `myResourceGroup` declaration in the Bicep file ensures that the resource group is created automatically if it doesn’t already exist.
   - If the group exists, Bicep skips creation and proceeds to deploy other resources.
   
2. **Simplified Workflow**:
   - No need for a separate `az group create` step, reducing manual effort.
   - Bicep takes care of the resource creation order.

3. **Better Maintainability**:
   - All infrastructure logic (resource group, VM, etc.) is defined in one place (Bicep).
   - Easier to replicate and manage deployments in different environments.

### Test the workflow by running it in your GitHub Actions.


### Confirm that both the resource group and the VM are successfully created.

---

## Tearing Down the Resource Group

We don’t want to forget about costs, so let’s create another workflow that cleans up resources once we’re done.

### Delete the Entire Resource Group

1. Create a new file `.github/workflows/destroy-resources.yml`.
2. Add this content:

   ```yaml
   name: Destroy Resources

   on: [workflow_dispatch]

   jobs:
     destroy-resources:
       runs-on: ubuntu-latest
       steps:
         - name: Checkout
           uses: actions/checkout@v3

         - name: Azure Login
           uses: azure/login@v1
           with:
             creds: ${{ secrets.AZURE_CREDENTIALS }}

         - name: Delete Resource Group
           run: |
             az group delete --name MyResourceGroup --yes --no-wait
   ```

3. Running this workflow will remove **everything** in `MyResourceGroup`. If you want finer control, skip deleting the group and instead remove individual resources manually (like we did on **Day 1**).

### Removing Individual Resources (Optional)

If you prefer to remove resources one by one, you can use multiple `az resource delete ...` commands. But for now, the **Resource Group** approach is the simplest.

---

## Preparing for Day 3

### Minimal Full-Stack Architecture Preview

Tomorrow, we’ll roll up our sleeves and deploy a **minimal full-stack architecture** for our startup. This will include setting up an **App Service**, a **Database**, and the **networking** pieces to tie it all together. We’ll do it all with Bicep and GitHub Actions so you can see how easy it is to scale up and tear down at will.

Stay tuned—exciting times ahead in the cloud!

**Hyped yet?** You’ve now created a GitHub Actions pipeline that securely connects to Azure, tested a simple command, deployed a VM via Bicep, and destroyed your resources to keep costs low. Day 3 will be all about that **minimal full-stack** deployment!
