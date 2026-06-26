targetScope = 'resourceGroup'

param location string
param environmentValue string
param appServicePlanId string
param catalogueApiUrl string

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: 'app-meridian-storefront-${environmentValue}'
  location: location
  kind: 'app'
  tags: {
    environment: environmentValue
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
          value: catalogueApiUrl
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environmentValue == 'prod' ? 'Production' : 'Development'
        }
      ]
    }
  }
}

// Slot-sticky settings stay with the slot on swap — prod slot always hits prod API, staging always hits nonprod API
resource stickySettings 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webApp
  name: 'slotConfigNames'
  properties: {
    appSettingNames: ['CATALOGUE_API_URL', 'ASPNETCORE_ENVIRONMENT']
  }
}

output webAppId string = webApp.id
output webAppName string = webApp.name
