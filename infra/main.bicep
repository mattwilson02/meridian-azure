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

@description('Alert notification email addresses — store in local params file only, do not commit.')
param securityAlertEmail string
param engineeringAlertEmail string
param cloudOpsAlertEmail string

// VM params commented out — compute module deployment blocked on Free Trial subscription (see modules/compute/main.bicep)
// @description('Local admin username for the HR/Finance VM.')
// param vmAdminUsername string
// @secure()
// param vmAdminPassword string

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

module storage './modules/storage/main.bicep' = {
  name: 'storage'
  dependsOn: [foundation]
  params: {
    location: location
  }
}

module compute './modules/compute/main.bicep' = {
  name: 'compute'
  dependsOn: [foundation]
  params: {}
}

module containers './modules/containers/main.bicep' = {
  name: 'containers'
  dependsOn: [foundation]
  params: {
    location: location
  }
}

// App Service Plans blocked on Free Trial — SubscriptionIsOverQuotaForSku (VM quota: 0)
// Uncomment after upgrading to PAYG
// module appService './modules/app-service/main.bicep' = {
//   name: 'appService'
//   params: {
//     location: location
//     prodCatalogueApiUrl: containers.outputs.prodCatalogueApiUrl
//     nonprodCatalogueApiUrl: containers.outputs.nonprodCatalogueApiUrl
//   }
// }

module networking './modules/networking/main.bicep' = {
  name: 'networking'
  dependsOn: [foundation]
  params: {
    location: location
    acrId: containers.outputs.acrId
    prodBlobStorageId: storage.outputs.prodBlobStorageId
    fileStorageId: storage.outputs.fileStorageId
  }
}

module monitoring './modules/monitoring/main.bicep' = {
  name: 'monitoring'
  dependsOn: [foundation]
  params: {
    location: location
    securityAlertEmail: securityAlertEmail
    engineeringAlertEmail: engineeringAlertEmail
    cloudOpsAlertEmail: cloudOpsAlertEmail
    prodBlobStorageName: storage.outputs.prodBlobStorageName
    fileStorageName: storage.outputs.fileStorageName
    nonprodBlobStorageName: storage.outputs.nonprodBlobStorageName
  }
}
