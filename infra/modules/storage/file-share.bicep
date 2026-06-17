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

// Reduced to 100GB minimum (study project — Premium bills on provisioned capacity regardless of usage).
// Production sizing: 600GB (500GB data + 100GB migration headroom); scale in 100GB increments at 90% alert.
resource financeShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  parent: fileService
  name: 'finance'
  properties: {
    shareQuota: 100
    enabledProtocols: 'SMB'
  }
}
