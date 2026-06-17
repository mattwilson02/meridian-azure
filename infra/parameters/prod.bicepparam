using '../main.bicep'

param location = 'uksouth'
param budgetStartDate = '<first-of-month-yyyy-MM-dd>'

// Entra group object IDs — created via runbook section 1.5
// Copy this file to prod.local.bicepparam and fill in real values (prod.local.bicepparam is gitignored)
// enablePim = true assumes prod tenant has Entra ID P2 licence
param enablePim = true
param itManagerGroupId = '<it-manager-group-object-id>'
param cloudEngineersGroupId = '<cloud-engineers-group-object-id>'
param headOfFinanceGroupId = '<head-of-finance-group-object-id>'
