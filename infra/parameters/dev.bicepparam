using '../main.bicep'

param location = 'uksouth'
param budgetStartDate = '2026-06-01'

// Entra group object IDs — replace with real values after running runbook section 1.5
// Copy this file to dev.local.bicepparam and fill in the values (dev.local.bicepparam is gitignored)
param itManagerGroupId = '<it-manager-group-object-id>'
param cloudEngineersGroupId = '<cloud-engineers-group-object-id>'
param headOfFinanceGroupId = '<head-of-finance-group-object-id>'

// Alert emails — copy to dev.local.bicepparam and fill in real addresses
param securityAlertEmail = '<security-alert-email>'
param engineeringAlertEmail = '<engineering-alert-email>'
param cloudOpsAlertEmail = '<cloudops-alert-email>'

// VM credentials — uncomment when compute module is re-enabled after subscription upgrade
// param vmAdminUsername = '<vm-admin-username>'
// param vmAdminPassword = '<vm-admin-password>'
