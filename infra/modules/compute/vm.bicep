targetScope = 'resourceGroup'

param location string
param subnetId string
param adminUsername string
@secure()
param adminPassword string

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-hrfinance-prod-ukw'
  location: location
  tags: {
    environment: 'prod'
    owner: 'unset'
    costCentre: 'unset'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: subnetId }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// Lift-and-shift of on-prem Windows Server HR/Finance app — IaaS required, migration complexity rules out containers
// Standard_D2s_v3: general purpose, 2 vCPU / 8GB RAM — deployed to ukwest due to capacity restrictions on all SKUs in uksouth for this subscription
// StandardSSD_LRS: OS disk only, no high-IOPS requirement — application data lives on the finance file share
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-hrfinance-prod-ukw'
  location: location
  tags: {
    environment: 'prod'
    owner: 'unset'
    costCentre: 'unset'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: 'hrfinance-prod'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
}

output vmId string = vm.id
output vmName string = vm.name
