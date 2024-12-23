@allowed([
  'nonprod'
  'prod'
])
param environmentType string

@description('Name of the Resource Group')
param resourceGroupName string

@description('Location of the Resource Group - by default, deploy all resources into the same location in which the resource group was created')
param resourceGroupLocation string = resourceGroup().location

@description('Storage Account Name')
param storageAccountName string = uniqueString(resourceGroup().id)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: rg.location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
