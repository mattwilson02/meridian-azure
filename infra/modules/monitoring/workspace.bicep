targetScope = 'resourceGroup'

param name string
param location string
param isProd bool = false

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: location
  tags: {
    environment: isProd ? 'prod' : 'nonprod'
    owner: 'cloud-engineering'
    costCentre: 'it'
  }
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Finance/HR access logs — 1 year retention for compliance (override workspace default)
// Commented out — SecurityEvent table requires Microsoft Sentinel or the Security solution
// to be active on the workspace. Neither is available on Free Trial.
// Reinstate after enabling Sentinel (requires Entra ID P2 / PAYG subscription).
// resource securityEventTable 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = if (isProd) {
//   parent: workspace
//   name: 'SecurityEvent'
//   properties: {
//     retentionInDays: 365
//     totalRetentionInDays: 365
//   }
// }

// Activity log — 90-day minimum regulatory requirement (override workspace default)
resource azureActivityTable 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = if (isProd) {
  parent: workspace
  name: 'AzureActivity'
  properties: {
    retentionInDays: 90
    totalRetentionInDays: 90
  }
}

output workspaceId string = workspace.id
output workspaceName string = workspace.name
