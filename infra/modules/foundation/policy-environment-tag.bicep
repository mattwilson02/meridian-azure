targetScope = 'resourceGroup'

@description('Value to set for the environment tag — prod or nonprod.')
param environmentValue string

@description('Resource ID of the environment tag policy definition — created at subscription scope in policies.bicep.')
param envTagDefinitionId string

// Assignment only — policyDefinitions cannot be created at resource group scope.
// The Modify effect requires a system-assigned identity to write tags on existing resources.

resource envTagAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'modify-environment-tag'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    policyDefinitionId: envTagDefinitionId
    displayName: 'Modify: environment tag = ${environmentValue}'
    enforcementMode: 'Default'
    parameters: {
      tagValue: {
        value: environmentValue
      }
    }
  }
}
