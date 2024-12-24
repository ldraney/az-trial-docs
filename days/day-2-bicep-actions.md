# **Day 2 - Bicep Filetree and GitHub Actions**

## **Table of Contents**
1. [Introduction](#introduction)  
2. [Azure RBAC Setup for GitHub Actions](#azure-rbac-setup-for-github-actions)  
   - [Creating a Service Principal](#creating-a-service-principal)  
   - [Assigning the Role](#assigning-the-role)  
   - [Storing Credentials in GitHub Secrets](#storing-credentials-in-github-secrets)  
3. [Testing Azure Connectivity with a Simple Workflow](#testing-azure-connectivity-with-a-simple-workflow)  
   - [Creating the GitHub Actions Workflow](#creating-the-github-actions-workflow)  
   - [Confirming Connectivity](#confirming-connectivity)  
4. [Why Bicep?](#why-bicep)  
5. [Repository File Tree & Bicep Modules](#repository-file-tree--bicep-modules)  
   - [File Tree Overview](#file-tree-overview)  
   - [Important GitHub Workflows](#important-github-workflows)  
   - [Bicep Modules](#bicep-modules)  
6. [Deploy a Resource Group and a Storage Account](#deploy-a-resource-group-and-a-storage-account)  
   - [Creating a Resource Group](#creating-a-resource-group)  
   - [Deploying a Storage Account](#deploying-a-storage-account)  
7. [Tearing Down Resources](#tearing-down-resources)  
   - [Deleting Modules Individually](#deleting-modules-individually)  
   - [Deleting the Entire Resource Group](#deleting-the-entire-resource-group)  
8. [Next Steps](#next-steps)

---

## **Introduction**

On **Day 1**, we manually created a resource group and a virtual machine via the Azure CLI, learning how to provision and clean up basic Azure resources. For **Day 2**, we’re taking that knowledge further by automating our deployments with **GitHub Actions** and **Bicep** templates. We’ll:

- Create a **Service Principal** and set up **RBAC** to give GitHub Actions permission to deploy resources in Azure.  
- Explore a **sample repository structure** for Bicep modules and workflows.  
- Deploy a **Storage Account** using your new CI/CD pipeline.  
- Tear down modules and resource groups to avoid incurring unexpected costs.  

Tomorrow (Day 3), we’ll expand on this by setting up a recommended Azure environment for a small startup—complete with containers and additional services. For now, let’s get our foundational pipeline working.

---

## **Azure RBAC Setup for GitHub Actions**

To allow GitHub Actions to interact with your Azure resources, you need a secure identity that can be used by your workflows.

### **Creating a Service Principal**

1. Open your **Azure Cloud Shell** (bash) or a local terminal with the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli).  
2. Run:
   ```bash
   az ad sp create-for-rbac \
     --name "github-actions-sp" \
     --role contributor \
     --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID> \
     --sdk-auth
   ```
   - Replace `<YOUR_SUBSCRIPTION_ID>` with the actual subscription ID (see Day 1 for finding your subscription with `az account list --output table`).  
3. You’ll see a JSON output containing details for clientId, clientSecret, subscriptionId, tenantId, etc. **Copy that entire JSON**.  

### **Assigning the Role**
- By using `--role contributor`, your Service Principal can create and manage resources.  
- You can tweak this role if you need different permissions (e.g., **Reader**, **Owner**, or a custom role).

### **Storing Credentials in GitHub Secrets**

1. In your **GitHub Repository**, go to **Settings** → **Secrets and variables** → **Actions**.  
2. Create a **New repository secret** named `AZURE_CREDENTIALS`.  
3. Paste the **entire JSON output** you copied from the service principal command into the **Value** field.  
4. Save it.

Done! Your Azure credentials are now securely stored. Let’s test them.

---

## **Testing Azure Connectivity with a Simple Workflow**

Before we jump into big deployments, let’s verify your GitHub Actions can log in to Azure.

### **Creating the GitHub Actions Workflow**

Create or update a file in `.github/workflows/list-resource-groups.yml`:

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

      - name: Show Subscription Name
        run: |
          az account show --query "{SubscriptionName:name}" -o json

      - name: Show Available Resource Groups
        run: |
          az group list --query "[].name" -o table
```

### **Confirming Connectivity**

1. Commit & push to your repo.  
2. Go to **Actions** → **Test Azure Connection** → **Run workflow**.  
3. Check the logs. You should see your subscription name and a list of resource groups. If yes, everything is set!

---

## **Why Bicep?**

Bicep is **Microsoft’s domain-specific language** (DSL) for declaring Azure resources in a clean, familiar syntax. It builds on ARM templates but is more concise and user-friendly. It also integrates seamlessly with Azure services and deployment tooling, making it a perfect candidate for an Azure-centric workflow.

- **Less JSON**: Bicep is easier to read/write than ARM templates.  
- **Better tooling**: Visual Studio Code provides strong Bicep support, including IntelliSense.  
- **Native Integration**: Fewer external dependencies compared to Terraform or other multi-cloud solutions (though those are also valid if you prefer them).

---

## **Repository File Tree & Bicep Modules**

### **File Tree Overview**

Below is a recommended repo structure that includes workflows and a sample `storage-account` module:

```
infra-repo/
├── .github/
│   └── workflows/
│       ├── create-resource-group.yml
│       ├── deploy-modules.yml
│       ├── delete-resource-group.yml
│       └── delete-modules.yml
├── modules/
│   └── storage-account/
│       ├── main.bicep
│       ├── variables.bicep
│       └── outputs.bicep
└── README.md
```

### **Important GitHub Workflows**

1. **create-resource-group.yml**: Creates a new Azure Resource Group.  
2. **deploy-modules.yml**: Deploys Bicep modules (like the `storage-account`) into that resource group.  
3. **delete-modules.yml**: Removes specific resources, leaving the RG intact.  
4. **delete-resource-group.yml**: Nukes the entire resource group and everything in it.

### **Bicep Modules**

Within `modules/`, each component (e.g., `storage-account`) typically has:
- **main.bicep**: The main deployment file with resource definitions.  
- **variables.bicep**: Common or reusable variables (SKU, location, etc.).  
- **outputs.bicep**: Exposes resource details (IDs, endpoints).

---

## **Deploy a Resource Group and a Storage Account**

### **Creating a Resource Group**

Your `.github/workflows/create-resource-group.yml` might look like this:

```yaml
name: Create Azure Resource Group

on:
  workflow_dispatch:
    inputs:
      resource_group_name:
        description: 'The name of the resource group to create'
        required: true
        default: 'MyResourceGroup'
      location:
        description: 'Azure region'
        required: true
        default: 'eastus'

jobs:
  create-resource-group:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Create Resource Group
        run: |
          az group create \
            --name ${{ github.event.inputs.resource_group_name }} \
            --location ${{ github.event.inputs.location }}
```

1. Run this workflow in the GitHub Actions UI.  
2. Verify the new resource group appears under **Azure Portal** → **Resource groups**.

### **Deploying a Storage Account**

Create or update `.github/workflows/deploy-modules.yml`:

```yaml
name: Deploy Azure Modules

on:
  workflow_dispatch:
    inputs:
      resource_group_name:
        description: 'Resource group name'
        required: true
      base_name:
        description: 'Base name for the storage account (unique suffix will be added)'
        required: true
      location:
        description: 'Storage account location'
        required: false
        default: 'eastus'

jobs:
  deploy-modules:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy Storage Account
        run: |
          az deployment group create \
            --resource-group ${{ github.event.inputs.resource_group_name }} \
            --template-file modules/storage-account/main.bicep \
            --parameters baseName=${{ github.event.inputs.base_name }} \
                         location=${{ github.event.inputs.location }}
```

Within `modules/storage-account/main.bicep`:
```bicep
param baseName string
param location string = resourceGroup().location
param skuName string = 'Standard_LRS'
param kind string = 'StorageV2'

var storageAccountName = toLower('${baseName}${uniqueString(resourceGroup().id)}')

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: kind
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
```

1. In GitHub Actions, find **Deploy Azure Modules** → **Run workflow**.  
2. Pass in a resource group name (created above) and a **base name** (e.g., `stor`).  
3. Confirm in the Azure Portal that a storage account has been created successfully.

---

## **Tearing Down Resources**

Once you’re done testing, it’s important to remove resources to avoid unnecessary costs.

### **Deleting Modules Individually**

If you only want to remove a storage account (and keep the resource group), create `.github/workflows/delete-modules.yml`:

```yaml
name: Delete Storage Account

on:
  workflow_dispatch:
    inputs:
      resource_group_name:
        description: 'Resource group'
        required: true
      storage_account_name:
        description: 'Name of the storage account'
        required: true

jobs:
  delete-modules:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Delete Storage Account
        run: |
          az storage account delete \
            --name ${{ github.event.inputs.storage_account_name }} \
            --resource-group ${{ github.event.inputs.resource_group_name }} \
            --yes
```

### **Deleting the Entire Resource Group**

If you want to wipe everything at once:

```yaml
name: Delete Resource Group

on:
  workflow_dispatch:
    inputs:
      resource_group_name:
        description: 'Resource group name'
        required: true

jobs:
  delete-resource-group:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Delete Resource Group
        run: |
          az group delete \
            --name ${{ github.event.inputs.resource_group_name }} \
            --yes \
            --no-wait
```

Check the Azure Portal or run `az group list -o table` to confirm it’s gone.

---

## **Next Steps**

- **Explore Shared Responsibility**: As a one-man startup, it’s crucial to understand what Azure manages (like physical infrastructure) and what you manage (like OS patches, data protection).  
- **App Service with Container**: Tomorrow (Day 3), we’ll deploy a minimal architecture including a containerized web app or an Nginx-based setup. This will give us an internet-accessible endpoint to further test.  
- **Keep an Eye on Costs**: Always verify you’ve torn down resources you don’t need. Check your credit balance regularly in **Cost Management + Billing**.  

That’s it for **Day 2**! You’ve established a robust foundation for automated deployments, leveraging GitHub Actions, Bicep, and secure RBAC in Azure. Tomorrow, we’ll continue to build on this momentum with a more advanced environment.

Happy automating!
