targetScope = 'resourceGroup'

param location string

// ── NSGs ──────────────────────────────────────────────────────────────────────

resource vmNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-vm-internal-uks'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowRdpFromBastion'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '10.0.0.128/26' // Bastion subnet service tag
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
      {
        name: 'DenyInternetInbound'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

// ── VNet ──────────────────────────────────────────────────────────────────────

resource internalVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-meridian-internal-uks'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.16.0/20']
    }
    subnets: [
      {
        name: 'snet-vm-internal-uks'
        properties: {
          addressPrefix: '10.0.16.0/24'
          networkSecurityGroup: { id: vmNsg.id }
        }
      }
      {
        name: 'snet-privateendpoints-internal-uks'
        properties: {
          addressPrefix: '10.0.17.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output internalVnetId string = internalVnet.id
output internalVnetName string = internalVnet.name
output vmSubnetId string = '${internalVnet.id}/subnets/snet-vm-internal-uks'
output privateEndpointSubnetId string = '${internalVnet.id}/subnets/snet-privateendpoints-internal-uks'
