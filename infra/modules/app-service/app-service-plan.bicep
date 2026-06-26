targetScope = 'resourceGroup'

param location string
param environmentValue string
param skuName string
param skuTier string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: 'asp-meridian-${environmentValue}-uks'
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  tags: {
    environment: environmentValue
    owner: 'cloud-engineering'
    costCentre: 'ecommerce'
  }
  properties: {
    reserved: false // Windows hosting — matches on-prem IIS migration target
  }
}

output appServicePlanId string = appServicePlan.id
