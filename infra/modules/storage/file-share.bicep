targetScope = 'resourceGroup'

param location string

// Premium FileStorage — SSD-backed, consistent IOPS for 11 concurrent Finance users
// LRS only — Premium FileStorage does not support GRS or ZRS

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'stmeridianfinanceuks'
  location: location
  kind: 'FileStorage'
  sku: {
    name: 'Premium_LRS'
  }
  tags: {
    environment: 'prod'
    owner: 'unset'
    costCentre: 'unset'
  }
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

// 600GB provisioned — 500GB current data plus 100GB migration headroom.
// Scale in 100GB increments when 90% capacity alert fires. See workloads.md.
resource financeShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  parent: fileService
  name: 'finance'
  properties: {
    shareQuota: 600
    enabledProtocols: 'SMB'
  }
}
