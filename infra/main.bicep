targetScope = 'subscription'

// ── Parameters ────────────────────────────────────────────────────────────────

@description('Primary Azure region for all resources.')
param location string = 'uksouth'

@description('Secondary region used for redundancy where applicable.')
param locationSecondary string = 'ukwest'

@description('Environment name — drives naming and policy.')
@allowed(['dev', 'prod'])
param environment string

// ── Modules ───────────────────────────────────────────────────────────────────
// Each module is added here as the corresponding exam domain is studied.
// Uncomment and configure each block when ready.

// module foundation './modules/foundation/main.bicep' = { ... }
// module compute    './modules/compute/main.bicep'    = { ... }
// module containers './modules/containers/main.bicep' = { ... }
// module appService './modules/app-service/main.bicep'= { ... }
// module networking './modules/networking/main.bicep' = { ... }
// module monitoring './modules/monitoring/main.bicep' = { ... }
