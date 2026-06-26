targetScope = 'subscription'

param location string
param prodCatalogueApiUrl string
param nonprodCatalogueApiUrl string

module prodPlan './app-service-plan.bicep' = {
  name: 'appservice-plan-prod'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    location: location
    environmentValue: 'prod'
    skuName: 'S1'
    skuTier: 'Standard'
  }
}

module nonprodPlan './app-service-plan.bicep' = {
  name: 'appservice-plan-nonprod'
  scope: resourceGroup('rg-meridian-nonprod-uks')
  params: {
    location: location
    environmentValue: 'nonprod'
    skuName: 'B1'
    skuTier: 'Basic'
  }
}

module prodWebApp './web-app.bicep' = {
  name: 'appservice-webapp-prod'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    location: location
    environmentValue: 'prod'
    appServicePlanId: prodPlan.outputs.appServicePlanId
    catalogueApiUrl: prodCatalogueApiUrl
  }
}

module nonprodWebApp './web-app.bicep' = {
  name: 'appservice-webapp-nonprod'
  scope: resourceGroup('rg-meridian-nonprod-uks')
  params: {
    location: location
    environmentValue: 'nonprod'
    appServicePlanId: nonprodPlan.outputs.appServicePlanId
    catalogueApiUrl: nonprodCatalogueApiUrl
  }
}

// Staging slot on prod web app only — connects to nonprod API via slot-sticky settings
module stagingSlot './staging-slot.bicep' = {
  name: 'appservice-staging-slot'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    location: location
    webAppName: prodWebApp.outputs.webAppName
    appServicePlanId: prodPlan.outputs.appServicePlanId
    nonprodCatalogueApiUrl: nonprodCatalogueApiUrl
  }
}
