targetScope = 'subscription'

param location string

module acr './acr.bicep' = {
  name: 'containers-acr'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    location: location
  }
}

// Correct design: separate environments per RG (cae-meridian-prod-uks, cae-meridian-nonprod-uks)
// Free Trial constraint: 1 Container Apps Environment per region — shared env workaround below
module sharedEnv './container-app-env.bicep' = {
  name: 'containers-env-shared'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    location: location
    environmentValue: 'shared'
  }
}

module prodApp './container-app.bicep' = {
  name: 'containers-app-prod'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    location: location
    environmentValue: 'prod'
    environmentId: sharedEnv.outputs.environmentId

    minReplicas: 0
  }
}

module nonprodApp './container-app.bicep' = {
  name: 'containers-app-nonprod'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    location: location
    environmentValue: 'nonprod'
    environmentId: sharedEnv.outputs.environmentId

    minReplicas: 0
  }
}

// AcrPull role assignments require system-assigned MI to be registered in Entra before assignment
// On Free Trial, MI provisioning times out — reinstate after upgrading to PAYG
// module acrPullProd './acr-role-assignment.bicep' = { ... }
// module acrPullNonprod './acr-role-assignment.bicep' = { ... }

output prodCatalogueApiUrl string = 'https://${prodApp.outputs.fqdn}'
output nonprodCatalogueApiUrl string = 'https://${nonprodApp.outputs.fqdn}'
output acrId string = acr.outputs.acrId
output acrName string = acr.outputs.acrName
output sharedEnvName string = sharedEnv.outputs.environmentName
