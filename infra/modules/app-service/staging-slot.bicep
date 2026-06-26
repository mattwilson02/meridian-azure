targetScope = 'resourceGroup'

param location string
param webAppName string
param appServicePlanId string
param nonprodCatalogueApiUrl string

resource stagingSlot 'Microsoft.Web/sites/slots@2023-01-01' = {
  name: '${webAppName}/staging'
  location: location
  kind: 'app'
  tags: {
    environment: 'staging'
    owner: 'cloud-engineering'
    costCentre: 'ecommerce'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      appSettings: [
        {
          name: 'CATALOGUE_API_URL'
          value: nonprodCatalogueApiUrl
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Staging'
        }
      ]
    }
  }
}
