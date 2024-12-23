@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the Virtual Machine.')
param vmName string = 'MyBicepVM'

resource myVM 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
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
      adminUsername: 'azureuser'
      adminPassword: 'ReplaceWithASecurePassword#123' // For example only—use Key Vault in real scenarios
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
