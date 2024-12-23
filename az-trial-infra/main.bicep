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
