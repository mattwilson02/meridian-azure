targetScope = 'subscription'

// ── Parameters ────────────────────────────────────────────────────────────────

@description('Primary region for all resources.')
param location string

@description('Budget start date — must be the first day of a month (yyyy-MM-dd).')
param budgetStartDate string

@description('Object IDs of Entra groups — created via runbook before deployment.')
param itManagerGroupId string
param cloudEngineersGroupId string
param headOfFinanceGroupId string

@description('Set to true only on tenants with Entra ID P2 licence — required for PIM role eligibility.')
param enablePim bool = false

// ── Resource Groups ───────────────────────────────────────────────────────────

module resourceGroups './resource-groups.bicep' = {
  name: 'foundation-resourceGroups'
  params: {
    location: location
  }
}

// ── Policies — subscription scope ────────────────────────────────────────────
// Study project: deployed at subscription scope (single subscription).
// In production with multiple subscriptions, deploy to root management group scope instead.

module policies './policies.bicep' = {
  name: 'foundation-policies'
}

// ── Policies — environment tag at RG scope ────────────────────────────────────
// Assigned at RG scope because tag value differs between environments.
// RG names are hardcoded — scope must be known at deployment plan time, not derived from outputs.

module prodEnvTag './policy-environment-tag.bicep' = {
  name: 'foundation-envTag-prod'
  scope: resourceGroup('rg-meridian-prod-uks')
  dependsOn: [resourceGroups]
  params: {
    environmentValue: 'prod'
    envTagDefinitionId: policies.outputs.envTagDefinitionId
  }
}

module nonProdEnvTag './policy-environment-tag.bicep' = {
  name: 'foundation-envTag-nonprod'
  scope: resourceGroup('rg-meridian-nonprod-uks')
  dependsOn: [resourceGroups]
  params: {
    environmentValue: 'nonprod'
    envTagDefinitionId: policies.outputs.envTagDefinitionId
  }
}

// ── Role Assignments — subscription scope ─────────────────────────────────────

module subRoleAssignments './role-assignments-sub.bicep' = {
  name: 'foundation-roleAssignments-sub'
  params: {
    headOfFinanceGroupId: headOfFinanceGroupId
  }
}

// ── Role Assignments — prod RG scope ─────────────────────────────────────────

module prodRoleAssignments './role-assignments-rg.bicep' = {
  name: 'foundation-roleAssignments-prod'
  scope: resourceGroup('rg-meridian-prod-uks')
  dependsOn: [resourceGroups]
  params: {
    itManagerGroupId: itManagerGroupId
    cloudEngineersGroupId: cloudEngineersGroupId
    isProd: true
    enablePim: enablePim
  }
}

// ── Role Assignments — non-prod RG scope ──────────────────────────────────────

module nonProdRoleAssignments './role-assignments-rg.bicep' = {
  name: 'foundation-roleAssignments-nonprod'
  scope: resourceGroup('rg-meridian-nonprod-uks')
  dependsOn: [resourceGroups]
  params: {
    itManagerGroupId: itManagerGroupId
    cloudEngineersGroupId: cloudEngineersGroupId
    isProd: false
    enablePim: enablePim
  }
}

// ── Cost Budgets ──────────────────────────────────────────────────────────────

module budgets './budgets.bicep' = {
  name: 'foundation-budgets'
  params: {
    startDate: budgetStartDate
  }
}
