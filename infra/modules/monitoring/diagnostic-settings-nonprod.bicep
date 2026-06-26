targetScope = 'resourceGroup'

param workspaceId string
param nonprodBlobStorageName string

resource nonprodBlobStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: nonprodBlobStorageName
}

resource nonprodBlobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' existing = {
  parent: nonprodBlobStorage
  name: 'default'
}

resource nonprodBlobDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-to-law-nonprod'
  scope: nonprodBlobService
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}
