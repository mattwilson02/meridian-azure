targetScope = 'resourceGroup'

param location string
param environmentValue string
param environmentId string
param minReplicas int

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'ca-catalogue-${environmentValue}-uks'
  location: location
  // Correct design: identity: { type: 'SystemAssigned' }
  // Free Trial: system-assigned MI causes Entra ID registration timeouts during provisioning — removed
  tags: {
    environment: environmentValue
    owner: 'cloud-engineering'
    costCentre: 'it'
  }
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      ingress: {
        external: true // change to false (internal) after VNet integration in networking module
        targetPort: 8080
        transport: 'http'
      }
      // Correct design: registries: [{ server: acrLoginServer, identity: 'system' }]
      // Removed — no MI on Free Trial, placeholder image is public
    }
    template: {
      containers: [
        {
          name: 'product-catalogue'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest' // replace with ACR image once pushed
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: 10
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
