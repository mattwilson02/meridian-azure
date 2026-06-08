targetScope = 'subscription'

// ── Parameters ────────────────────────────────────────────────────────────────

@description('Primary Azure region for all resources.')
param location string = 'uksouth'

@description('Budget start date — must be the first day of a month (yyyy-MM-dd).')
param budgetStartDate string

@description('Entra group object IDs — created via runbook before deployment. See runbook.md section 1.5.')
param itManagerGroupId string
param cloudEngineersGroupId string
param headOfFinanceGroupId string

@description('Set to true only on tenants with Entra ID P2 licence — required for PIM role eligibility.')
param enablePim bool = false

// ── Modules ───────────────────────────────────────────────────────────────────

module foundation './modules/foundation/main.bicep' = {
  name: 'foundation'
  params: {
    location: location
    budgetStartDate: budgetStartDate
    itManagerGroupId: itManagerGroupId
    cloudEngineersGroupId: cloudEngineersGroupId
    headOfFinanceGroupId: headOfFinanceGroupId
    enablePim: enablePim
  }
}

// module compute    './modules/compute/main.bicep'    = { ... }
// module containers './modules/containers/main.bicep' = { ... }
// module appService './modules/app-service/main.bicep'= { ... }
// module networking './modules/networking/main.bicep' = { ... }
// module monitoring './modules/monitoring/main.bicep' = { ... }
