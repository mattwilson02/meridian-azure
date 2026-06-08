// Study project: policies deployed at subscription scope.
// In a multi-subscription production estate, move this to a separate management-group-scoped
// deployment so policies cascade across all subscriptions automatically.
targetScope = 'subscription'

// ── Region Enforcement ────────────────────────────────────────────────────────
// Built-in: Allowed locations
// Effect: Deny — hard compliance requirement, no valid exceptions

var allowedLocationsPolicyId = 'e56962a6-4747-49cd-b67b-bf8b01975c4c'
var contributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource locationPolicyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'deny-nonuk-locations'
  properties: {
    policyDefinitionId: tenantResourceId(
      'Microsoft.Authorization/policyDefinitions',
      allowedLocationsPolicyId
    )
    displayName: 'Deny: non-UK regions'
    enforcementMode: 'Default'
    parameters: {
      listOfAllowedLocations: {
        value: ['uksouth', 'ukwest']
      }
    }
  }
}

// ── Tag: owner (Audit) ────────────────────────────────────────────────────────
// Effect: Audit — tighten to Deny post-migration once tagging is established

resource ownerTagDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'audit-owner-tag-missing'
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Audit: owner tag missing on resources'
    policyRule: {
      if: {
        field: 'tags[owner]'
        exists: false
      }
      then: {
        effect: 'audit'
      }
    }
  }
}

resource ownerTagAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'audit-owner-tag'
  properties: {
    policyDefinitionId: ownerTagDefinition.id
    displayName: 'Audit: owner tag missing'
    enforcementMode: 'Default'
  }
}

// ── Tag: costCentre (Audit) ───────────────────────────────────────────────────
// Effect: Audit — tighten to Deny post-migration once tagging is established

resource costCentreTagDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'audit-costcentre-tag-missing'
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Audit: costCentre tag missing on resources'
    policyRule: {
      if: {
        field: 'tags[costCentre]'
        exists: false
      }
      then: {
        effect: 'audit'
      }
    }
  }
}

resource costCentreTagAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'audit-costcentre-tag'
  properties: {
    policyDefinitionId: costCentreTagDefinition.id
    displayName: 'Audit: costCentre tag missing'
    enforcementMode: 'Default'
  }
}

// ── Tag: environment (Modify) — definition only ───────────────────────────────
// Assignment is at RG scope (prod/nonprod have different values) — see policy-environment-tag.bicep
// policyDefinitions cannot be created at RG scope, so the definition lives here at subscription scope.

resource envTagDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'modify-environment-tag'
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Modify: add environment tag on resources'
    policyRule: {
      if: {
        field: 'tags[environment]'
        exists: false
      }
      then: {
        effect: 'modify'
        details: {
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/${contributorRoleId}'
          ]
          operations: [
            {
              operation: 'addOrReplace'
              field: 'tags[environment]'
              value: '[parameters(\'tagValue\')]'
            }
          ]
        }
      }
    }
    parameters: {
      tagValue: {
        type: 'String'
      }
    }
  }
}

output envTagDefinitionId string = envTagDefinition.id
