targetScope = 'resourceGroup'

param location string

// Minimal VNet scoped to compute — networking module will expand with Bastion, VPN, DNS, peering
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-meridian-prod-ukw'
  location: location
  tags: {
    environment: 'prod'
    owner: 'unset'
    costCentre: 'unset'
  }
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'snet-compute-prod-ukw'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
