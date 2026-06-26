targetScope = 'subscription'

param location string

// Resource IDs passed in from other modules for private endpoint configuration
param acrId string
param prodBlobStorageId string
param fileStorageId string

// ── VNets ─────────────────────────────────────────────────────────────────────

module hub './hub.bicep' = {
  name: 'networking-hub'
  scope: resourceGroup('rg-meridian-network-uks')
  params: {
    location: location
  }
}

module spokeInternal './spoke-internal.bicep' = {
  name: 'networking-spoke-internal'
  scope: resourceGroup('rg-meridian-network-uks')
  params: {
    location: location
  }
}

module spokeEcommerce './spoke-ecommerce.bicep' = {
  name: 'networking-spoke-ecommerce'
  scope: resourceGroup('rg-meridian-network-uks')
  params: {
    location: location
  }
}

// ── Peering ───────────────────────────────────────────────────────────────────

module peering './peering.bicep' = {
  name: 'networking-peering'
  scope: resourceGroup('rg-meridian-network-uks')
  params: {
    hubVnetName: hub.outputs.hubVnetName
    hubVnetId: hub.outputs.hubVnetId
    internalVnetName: spokeInternal.outputs.internalVnetName
    internalVnetId: spokeInternal.outputs.internalVnetId
    ecommerceVnetName: spokeEcommerce.outputs.ecommerceVnetName
    ecommerceVnetId: spokeEcommerce.outputs.ecommerceVnetId
  }
}

// ── UDRs ──────────────────────────────────────────────────────────────────────

module udr './udr.bicep' = {
  name: 'networking-udr'
  scope: resourceGroup('rg-meridian-network-uks')
  params: {}
}

// ── Private DNS Zones ─────────────────────────────────────────────────────────

module privateDns './private-dns.bicep' = {
  name: 'networking-private-dns'
  scope: resourceGroup('rg-meridian-network-uks')
  params: {
    hubVnetId: hub.outputs.hubVnetId
    internalVnetId: spokeInternal.outputs.internalVnetId
    ecommerceVnetId: spokeEcommerce.outputs.ecommerceVnetId
  }
}

// ── Private Endpoints ─────────────────────────────────────────────────────────

module privateEndpoints './private-endpoint.bicep' = {
  name: 'networking-private-endpoints'
  scope: resourceGroup('rg-meridian-network-uks')
  params: {
    location: location
    acrId: acrId
    blobStorageId: prodBlobStorageId
    fileStorageId: fileStorageId
    ecommercePrivateEndpointSubnetId: spokeEcommerce.outputs.privateEndpointSubnetId
    internalPrivateEndpointSubnetId: spokeInternal.outputs.privateEndpointSubnetId
    acrDnsZoneId: privateDns.outputs.acrDnsZoneId
    blobDnsZoneId: privateDns.outputs.blobDnsZoneId
    fileDnsZoneId: privateDns.outputs.fileDnsZoneId
  }
}
