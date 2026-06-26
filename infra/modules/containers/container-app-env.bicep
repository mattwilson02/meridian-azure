targetScope = 'resourceGroup'

param location string
param environmentValue string

resource containerAppsEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: 'cae-meridian-${environmentValue}-uks'
  location: location
  tags: {
    environment: environmentValue
    owner: 'cloud-engineering'
    costCentre: 'it'
  }
  properties: {
    // VNet integration and internal ingress deferred to networking module
  }
}

output environmentId string = containerAppsEnv.id
output environmentName string = containerAppsEnv.name
