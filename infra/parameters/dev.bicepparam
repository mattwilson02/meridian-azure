using '../main.bicep'

param location = 'uksouth'
param budgetStartDate = '2026-06-01'

// Entra group object IDs — replace with real values after running runbook section 1.5
// Copy this file to dev.local.bicepparam and fill in the values (dev.local.bicepparam is gitignored)
param itManagerGroupId = '<it-manager-group-object-id>'
param cloudEngineersGroupId = '<cloud-engineers-group-object-id>'
param headOfFinanceGroupId = '<head-of-finance-group-object-id>'
