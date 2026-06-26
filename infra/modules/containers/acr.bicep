targetScope = 'resourceGroup'

param location string

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: 'acrmeridianretailuks'
  location: location
  sku: {
    name: 'Premium'
  }
  tags: {
    environment: 'prod'
    owner: 'cloud-engineering'
    costCentre: 'it'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled' // private endpoint deferred to networking module
  }
}

output acrId string = acr.id
output acrName string = acr.name
output acrLoginServer string = acr.properties.loginServer
