targetScope = 'resourceGroup'

// Params used by active alerts
param agCloudOpsId string
param fileStorageName string

// Params for Container Apps / App Service / VM alerts — uncomment when reinstating those resources (PAYG required)
// param location string
// param workspaceId string
// param agSecurityId string
// param agEngineeringId string
// param containerAppName string

// ── Existing resource references ───────────────────────────────────────────────

// Container App reference commented out — ca-catalogue-prod-uks not deployed on Free Trial
// (ContainerAppOperationError: Operation expired during revision provisioning)
// Reinstate after upgrading subscription to PAYG
// resource prodContainerApp 'Microsoft.App/containerApps@2024-03-01' existing = {
//   name: containerAppName
// }

resource fileStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: fileStorageName
}

// ── Metric Alerts ──────────────────────────────────────────────────────────────

// Catalogue API — >10 5xx responses in a 5-minute window
// Commented out — Container App not deployed on Free Trial (see above)
// resource alertCatalogue5xx 'Microsoft.Insights/metricAlerts@2018-03-01' = {
//   name: 'alert-catalogue-5xx-prod'
//   location: 'global'
//   tags: { environment: 'prod'; owner: 'cloud-engineering'; costCentre: 'it' }
//   properties: {
//     description: 'Catalogue API returning >10 5xx errors in 5 minutes'
//     severity: 2
//     enabled: true
//     scopes: [prodContainerApp.id]
//     evaluationFrequency: 'PT1M'
//     windowSize: 'PT5M'
//     criteria: {
//       'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
//       allOf: [{ name: '5xx-count'; metricName: 'Requests'; metricNamespace: 'Microsoft.App/containerApps'
//         dimensions: [{ name: 'StatusCodeCategory'; operator: 'Include'; values: ['5xx'] }]
//         operator: 'GreaterThan'; threshold: 10; timeAggregation: 'Total'; criterionType: 'StaticThresholdCriterion' }]
//     }
//     actions: [{ actionGroupId: agEngineeringId }]
//   }
// }

// Finance file share — storage account availability below 99%
resource alertFileShareAvailability 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-fileshare-availability-prod'
  location: 'global'
  tags: {
    environment: 'prod'
    owner: 'cloud-engineering'
    costCentre: 'it'
  }
  properties: {
    description: 'Finance file share storage availability below 99%'
    severity: 1
    enabled: true
    scopes: [fileStorageAccount.id]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'availability'
          metricName: 'Availability'
          metricNamespace: 'Microsoft.Storage/storageAccounts'
          operator: 'LessThan'
          threshold: 99
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: [
      {
        actionGroupId: agCloudOpsId
      }
    ]
  }
}

// ── Commented out: requires App Service deployment (upgrade subscription to PAYG) ──

// App Service — HTTP 5xx rate
// resource alertStorefront5xx 'Microsoft.Insights/metricAlerts@2018-03-01' = {
//   name: 'alert-storefront-5xx-prod'
//   location: 'global'
//   properties: {
//     description: 'Storefront returning >10 5xx errors in 5 minutes'
//     severity: 2
//     enabled: true
//     scopes: ['/subscriptions/<sub-id>/resourceGroups/rg-meridian-prod-uks/providers/Microsoft.Web/sites/app-meridian-storefront-prod']
//     evaluationFrequency: 'PT1M'
//     windowSize: 'PT5M'
//     criteria: {
//       'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
//       allOf: [{ name: 'http5xx'; metricName: 'Http5xx'; operator: 'GreaterThan'; threshold: 10; timeAggregation: 'Total'; criterionType: 'StaticThresholdCriterion' }]
//     }
//     actions: [{ actionGroupId: agEngineeringId }]
//   }
// }

// App Service — HTTP 404 rate
// resource alertStorefront404 'Microsoft.Insights/metricAlerts@2018-03-01' = {
//   name: 'alert-storefront-404-prod'
//   location: 'global'
//   properties: {
//     description: 'Elevated 404 rate on storefront — possible broken links or crawl activity'
//     severity: 3
//     scopes: ['/subscriptions/<sub-id>/resourceGroups/rg-meridian-prod-uks/providers/Microsoft.Web/sites/app-meridian-storefront-prod']
//     criteria: {
//       'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
//       allOf: [{ name: 'http404'; metricName: 'Http404Count'; operator: 'GreaterThan'; threshold: 50; timeAggregation: 'Total'; criterionType: 'StaticThresholdCriterion' }]
//     }
//     actions: [{ actionGroupId: agEngineeringId }]
//   }
// }

// VM CPU > 80% — requires VM deployment
// resource alertVmCpu 'Microsoft.Insights/metricAlerts@2018-03-01' = {
//   name: 'alert-vm-cpu-prod'
//   location: 'global'
//   properties: {
//     description: 'HR/Finance VM CPU sustained above 80%'
//     severity: 2
//     scopes: ['/subscriptions/<sub-id>/resourceGroups/rg-meridian-prod-uks/providers/Microsoft.Compute/virtualMachines/vm-hrfinance-prod-ukw']
//     evaluationFrequency: 'PT1M'
//     windowSize: 'PT5M'
//     criteria: {
//       'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
//       allOf: [{ name: 'cpu'; metricName: 'Percentage CPU'; operator: 'GreaterThan'; threshold: 80; timeAggregation: 'Average'; criterionType: 'StaticThresholdCriterion' }]
//     }
//     actions: [{ actionGroupId: agCloudOpsId }]
//   }
// }

// ── Commented out: requires VM + Azure Monitor Agent Data Collection Rules ─────
// SecurityEvent data is only available after AMA is installed on the VM and a DCR
// is configured to collect Windows Security Event logs.

// RDP brute force — >10 failed logons (EventID 4625, LogonType 3) in 5 min
// resource alertRdpBruteForce 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
//   name: 'alert-rdp-bruteforce-prod'
//   location: location
//   properties: {
//     description: 'Possible RDP brute force — >10 failed network logons in 5 minutes'
//     severity: 0
//     enabled: true
//     scopes: [workspaceId]
//     evaluationFrequency: 'PT5M'
//     windowSize: 'PT5M'
//     criteria: {
//       allOf: [{
//         query: '''
//           SecurityEvent
//           | where EventID == 4625 and LogonType == 3
//           | summarize FailedAttempts = count() by bin(TimeGenerated, 5m), Computer, IpAddress
//           | where FailedAttempts > 10
//         '''
//         timeAggregation: 'Count'; operator: 'GreaterThan'; threshold: 0
//         failingPeriods: { numberOfEvaluationPeriods: 1; minFailingPeriodsToAlert: 1 }
//       }]
//     }
//     actions: { actionGroups: [agSecurityId] }
//   }
// }

// App authentication failures — >5 non-network logon failures in 5 min
// resource alertAuthFailures 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
//   name: 'alert-auth-failures-prod'
//   location: location
//   properties: {
//     description: 'Elevated application authentication failures on HR/Finance VM'
//     severity: 2
//     enabled: true
//     scopes: [workspaceId]
//     evaluationFrequency: 'PT5M'
//     windowSize: 'PT5M'
//     criteria: {
//       allOf: [{
//         query: '''
//           SecurityEvent
//           | where EventID == 4625 and LogonType != 3
//           | summarize Failures = count() by bin(TimeGenerated, 5m), Account, Computer
//           | where Failures > 5
//         '''
//         timeAggregation: 'Count'; operator: 'GreaterThan'; threshold: 0
//         failingPeriods: { numberOfEvaluationPeriods: 1; minFailingPeriodsToAlert: 1 }
//       }]
//     }
//     actions: { actionGroups: [agEngineeringId] }
//   }
// }
