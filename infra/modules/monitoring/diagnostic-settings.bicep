targetScope = 'resourceGroup'

param workspaceId string
param prodBlobStorageName string
param fileStorageName string

// containerAppsEnvName — uncomment when Container Apps environment is confirmed deployed (PAYG required)
// param containerAppsEnvName string

// ── Prod blob storage (assets) ─────────────────────────────────────────────────

resource prodBlobStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: prodBlobStorageName
}

resource prodBlobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' existing = {
  parent: prodBlobStorage
  name: 'default'
}

resource prodBlobDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-to-law-prod'
  scope: prodBlobService
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

// ── Finance file share storage ─────────────────────────────────────────────────
// Premium FileStorage only — blob service does not exist on this account

resource fileStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: fileStorageName
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' existing = {
  parent: fileStorage
  name: 'default'
}

resource fileStorageDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-to-law-prod'
  scope: fileService
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

// ── Container Apps environment (shared env — prod + nonprod apps) ──────────────
// Commented out — cae-meridian-shared-uks provisioning timed out on Free Trial
// (ContainerAppOperationError: Operation expired). Environment may not exist in Azure.
// Reinstate after upgrading subscription to PAYG and confirming environment is deployed.

// resource containerAppsEnv 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
//   name: containerAppsEnvName
// }
// resource containerAppsEnvDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: 'diag-to-law-prod'
//   scope: containerAppsEnv
//   properties: {
//     workspaceId: workspaceId
//     logs: [
//       { category: 'ContainerAppSystemLogs'; enabled: true }
//       { category: 'ContainerAppConsoleLogs'; enabled: true }
//     ]
//   }
// }

// ── Commented out: App Service — uncomment after upgrading to PAYG ─────────────

// resource appService 'Microsoft.Web/sites@2022-03-01' existing = {
//   name: 'app-meridian-storefront-prod'
// }
// resource appServiceDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: 'diag-to-law-prod'
//   scope: appService
//   properties: {
//     workspaceId: workspaceId
//     logs: [
//       { category: 'AppServiceHTTPLogs'; enabled: true }
//       { category: 'AppServiceAppLogs'; enabled: true }
//       { category: 'AppServiceConsoleLogs'; enabled: true }
//       { category: 'AppServiceAuditLogs'; enabled: true }
//     ]
//     metrics: [{ category: 'AllMetrics'; enabled: true }]
//   }
// }

// ── VM — configure via Azure Monitor Agent + Data Collection Rules ─────────────
// Diagnostic settings cannot collect SecurityEvent or guest OS metrics.
// Install AMA on the VM and create a DCR targeting the prod workspace.
// Reinstate after VM deployment post-subscription upgrade.
