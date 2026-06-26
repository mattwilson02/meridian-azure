targetScope = 'resourceGroup'

param hubVnetId string
param internalVnetId string
param ecommerceVnetId string

// ── Private DNS Zones ─────────────────────────────────────────────────────────

resource acrDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurecr.io'
  location: 'global'
}

resource blobDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
}

resource fileDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.file.${environment().suffixes.storage}'
  location: 'global'
}

// ── VNet Links — each zone linked to all three VNets for cross-VNet resolution ──

resource acrZoneLinkHub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: acrDnsZone
  name: 'link-acr-hub'
  location: 'global'
  properties: { virtualNetwork: { id: hubVnetId }, registrationEnabled: false }
}

resource acrZoneLinkInternal 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: acrDnsZone
  name: 'link-acr-internal'
  location: 'global'
  properties: { virtualNetwork: { id: internalVnetId }, registrationEnabled: false }
}

resource acrZoneLinkEcommerce 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: acrDnsZone
  name: 'link-acr-ecommerce'
  location: 'global'
  properties: { virtualNetwork: { id: ecommerceVnetId }, registrationEnabled: false }
}

resource blobZoneLinkHub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobDnsZone
  name: 'link-blob-hub'
  location: 'global'
  properties: { virtualNetwork: { id: hubVnetId }, registrationEnabled: false }
}

resource blobZoneLinkInternal 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobDnsZone
  name: 'link-blob-internal'
  location: 'global'
  properties: { virtualNetwork: { id: internalVnetId }, registrationEnabled: false }
}

resource blobZoneLinkEcommerce 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobDnsZone
  name: 'link-blob-ecommerce'
  location: 'global'
  properties: { virtualNetwork: { id: ecommerceVnetId }, registrationEnabled: false }
}

resource fileZoneLinkHub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: fileDnsZone
  name: 'link-file-hub'
  location: 'global'
  properties: { virtualNetwork: { id: hubVnetId }, registrationEnabled: false }
}

resource fileZoneLinkInternal 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: fileDnsZone
  name: 'link-file-internal'
  location: 'global'
  properties: { virtualNetwork: { id: internalVnetId }, registrationEnabled: false }
}

resource fileZoneLinkEcommerce 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: fileDnsZone
  name: 'link-file-ecommerce'
  location: 'global'
  properties: { virtualNetwork: { id: ecommerceVnetId }, registrationEnabled: false }
}

output acrDnsZoneId string = acrDnsZone.id
output blobDnsZoneId string = blobDnsZone.id
output fileDnsZoneId string = fileDnsZone.id
