targetScope = 'subscription'

param location string
param securityAlertEmail string
param engineeringAlertEmail string
param cloudOpsAlertEmail string
param prodBlobStorageName string
param fileStorageName string
param nonprodBlobStorageName string

// containerAppsEnvName — uncomment when Container Apps environment is confirmed deployed (PAYG required)
// param containerAppsEnvName string

// ── Log Analytics Workspaces ───────────────────────────────────────────────────

module prodWorkspace './workspace.bicep' = {
  name: 'monitoring-workspace-prod'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    name: 'law-meridian-prod-uks'
    location: location
    isProd: true
  }
}

module nonprodWorkspace './workspace.bicep' = {
  name: 'monitoring-workspace-nonprod'
  scope: resourceGroup('rg-meridian-nonprod-uks')
  params: {
    name: 'law-meridian-nonprod-uks'
    location: location
    isProd: false
  }
}

// ── Subscription-level activity log routing ────────────────────────────────────
// Both workspaces receive activity logs — prod for alerting, nonprod for dev visibility

resource activityLogToProd 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'sub-activitylog-to-prod'
  properties: {
    workspaceId: prodWorkspace.outputs.workspaceId
    logs: [
      {
        category: 'Administrative'
        enabled: true
      }
      {
        category: 'Security'
        enabled: true
      }
      {
        category: 'ServiceHealth'
        enabled: true
      }
      {
        category: 'Alert'
        enabled: true
      }
      {
        category: 'Recommendation'
        enabled: true
      }
      {
        category: 'Policy'
        enabled: true
      }
      {
        category: 'Autoscale'
        enabled: true
      }
      {
        category: 'ResourceHealth'
        enabled: true
      }
    ]
  }
}

resource activityLogToNonprod 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'sub-activitylog-to-nonprod'
  properties: {
    workspaceId: nonprodWorkspace.outputs.workspaceId
    logs: [
      {
        category: 'Administrative'
        enabled: true
      }
      {
        category: 'Security'
        enabled: true
      }
      {
        category: 'ServiceHealth'
        enabled: true
      }
      {
        category: 'Alert'
        enabled: true
      }
      {
        category: 'Recommendation'
        enabled: true
      }
      {
        category: 'Policy'
        enabled: true
      }
      {
        category: 'Autoscale'
        enabled: true
      }
      {
        category: 'ResourceHealth'
        enabled: true
      }
    ]
  }
}

// ── Application Insights (prod only) ──────────────────────────────────────────

module storefrontAppInsights './app-insights.bicep' = {
  name: 'monitoring-appinsights-storefront'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    name: 'appi-meridian-storefront-prod'
    location: location
    workspaceId: prodWorkspace.outputs.workspaceId
  }
}

module catalogueAppInsights './app-insights.bicep' = {
  name: 'monitoring-appinsights-catalogue'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    name: 'appi-meridian-catalogue-prod'
    location: location
    workspaceId: prodWorkspace.outputs.workspaceId
  }
}

// ── Action groups (prod only) ──────────────────────────────────────────────────

module actionGroups './action-groups.bicep' = {
  name: 'monitoring-action-groups'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    securityEmail: securityAlertEmail
    engineeringEmail: engineeringAlertEmail
    cloudOpsEmail: cloudOpsAlertEmail
  }
}

// ── Alerts (prod only) ────────────────────────────────────────────────────────

module alerts './alerts.bicep' = {
  name: 'monitoring-alerts'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    agCloudOpsId: actionGroups.outputs.agCloudOpsId
    fileStorageName: fileStorageName
  }
}

// ── Diagnostic settings ────────────────────────────────────────────────────────

module prodDiagSettings './diagnostic-settings.bicep' = {
  name: 'monitoring-diag-prod'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    workspaceId: prodWorkspace.outputs.workspaceId
    prodBlobStorageName: prodBlobStorageName
    fileStorageName: fileStorageName
  }
}

module nonprodDiagSettings './diagnostic-settings-nonprod.bicep' = {
  name: 'monitoring-diag-nonprod'
  scope: resourceGroup('rg-meridian-nonprod-uks')
  params: {
    workspaceId: nonprodWorkspace.outputs.workspaceId
    nonprodBlobStorageName: nonprodBlobStorageName
  }
}

// ── Outputs ───────────────────────────────────────────────────────────────────

output prodWorkspaceId string = prodWorkspace.outputs.workspaceId
output storefrontConnectionString string = storefrontAppInsights.outputs.connectionString
output catalogueConnectionString string = catalogueAppInsights.outputs.connectionString
