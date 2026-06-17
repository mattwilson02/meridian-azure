targetScope = 'resourceGroup'

param location string
param vmId string
param vmName string
param financeStorageAccountName string

resource vault 'Microsoft.RecoveryServices/vaults@2023-04-01' = {
  name: 'rsv-meridian-prod-ukw'
  location: location
  tags: {
    environment: 'prod'
    owner: 'unset'
    costCentre: 'unset'
  }
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource vmBackupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-04-01' = {
  parent: vault
  name: 'policy-vm-daily'
  properties: {
    backupManagementType: 'AzureIaasVM'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: ['2000-01-01T02:00:00Z']
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: ['2000-01-01T02:00:00Z']
        retentionDuration: {
          count: 30
          durationType: 'Days'
        }
      }
    }
    instantRpRetentionRangeInDays: 2
    timeZone: 'GMT Standard Time'
  }
}

resource fileShareBackupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2023-04-01' = {
  parent: vault
  name: 'policy-fileshare-daily'
  properties: {
    backupManagementType: 'AzureStorage'
    workLoadType: 'AzureFileShare'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: ['2000-01-01T02:00:00Z']
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: ['2000-01-01T02:00:00Z']
        retentionDuration: {
          count: 30
          durationType: 'Days'
        }
      }
    }
    timeZone: 'GMT Standard Time'
  }
}

// Register the finance storage account with the vault so file share backup can be configured
resource storageContainer 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2023-04-01' = {
  name: '${vault.name}/Azure/StorageContainer;Storage;${resourceGroup().name};${financeStorageAccountName}'
  properties: {
    containerType: 'StorageContainer'
    backupManagementType: 'AzureStorage'
    sourceResourceId: resourceId('Microsoft.Storage/storageAccounts', financeStorageAccountName)
  }
  dependsOn: [fileShareBackupPolicy]
}

resource financeShareProtectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2023-04-01' = {
  parent: storageContainer
  name: 'AzureFileShare;finance'
  properties: {
    protectedItemType: 'AzureFileShareProtectedItem'
    sourceResourceId: resourceId('Microsoft.Storage/storageAccounts', financeStorageAccountName)
    policyId: fileShareBackupPolicy.id
  }
}

resource vmProtectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2023-04-01' = {
  name: '${vault.name}/Azure/IaasVMContainer;iaasvmcontainerv2;${resourceGroup().name};${vmName}/VM;iaasvmcontainerv2;${resourceGroup().name};${vmName}'
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    sourceResourceId: vmId
    policyId: vmBackupPolicy.id
  }
}
