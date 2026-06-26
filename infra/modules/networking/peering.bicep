targetScope = 'resourceGroup'

param hubVnetName string
param hubVnetId string
param internalVnetName string
param internalVnetId string
param ecommerceVnetName string
param ecommerceVnetId string

// ── Hub → Internal ────────────────────────────────────────────────────────────

resource hubToInternal 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${hubVnetName}/peer-hub-to-internal'
  properties: {
    remoteVirtualNetwork: { id: internalVnetId }
    allowForwardedTraffic: true
    allowGatewayTransit: true // hub shares VPN Gateway with spokes
    useRemoteGateways: false
  }
}

resource internalToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${internalVnetName}/peer-internal-to-hub'
  properties: {
    remoteVirtualNetwork: { id: hubVnetId }
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false // set to true after VPN Gateway is provisioned
  }
  dependsOn: [hubToInternal]
}

// ── Hub → Ecommerce ───────────────────────────────────────────────────────────

resource hubToEcommerce 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${hubVnetName}/peer-hub-to-ecommerce'
  properties: {
    remoteVirtualNetwork: { id: ecommerceVnetId }
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}

resource ecommerceToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${ecommerceVnetName}/peer-ecommerce-to-hub'
  properties: {
    remoteVirtualNetwork: { id: hubVnetId }
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false // set to true after VPN Gateway is provisioned
  }
  dependsOn: [hubToEcommerce]
}
