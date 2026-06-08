targetScope = 'resourceGroup'

param itManagerGroupId string
param cloudEngineersGroupId string

@description('True for the prod RG, false for non-prod — controls which assignments are created.')
param isProd bool

@description('Set to true only on tenants with Entra ID P2 licence — required for PIM role eligibility.')
param enablePim bool = false

var monitoringReaderRoleId = '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
var contributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

// ── IT Manager ────────────────────────────────────────────────────────────────
// Prod only — emergency access and monitoring visibility

resource itManagerMonitoringReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (isProd) {
  name: guid(resourceGroup().id, itManagerGroupId, monitoringReaderRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', monitoringReaderRoleId)
    principalId: itManagerGroupId
    principalType: 'Group'
  }
}

resource itManagerContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (isProd) {
  name: guid(resourceGroup().id, itManagerGroupId, contributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
    principalId: itManagerGroupId
    principalType: 'Group'
  }
}

// ── Cloud Engineers ───────────────────────────────────────────────────────────
// Monitoring Reader on both RGs; permanent Contributor on non-prod; PIM-eligible on prod

resource cloudEngineersMonitoringReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, cloudEngineersGroupId, monitoringReaderRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', monitoringReaderRoleId)
    principalId: cloudEngineersGroupId
    principalType: 'Group'
  }
}

resource cloudEngineersContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!isProd) {
  name: guid(resourceGroup().id, cloudEngineersGroupId, contributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
    principalId: cloudEngineersGroupId
    principalType: 'Group'
  }
}

// PIM-eligible Contributor on prod — Cloud Engineers request activation, approved by IT Manager
resource cloudEngineersProdPIM 'Microsoft.Authorization/roleEligibilityScheduleRequests@2022-04-01-preview' = if (isProd && enablePim) {
  name: guid(resourceGroup().id, cloudEngineersGroupId, contributorRoleId, 'pim-eligible')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
    principalId: cloudEngineersGroupId
    requestType: 'AdminAssign'
    scheduleInfo: {
      expiration: {
        type: 'NoExpiration'
      }
    }
  }
}
