targetScope = 'resourceGroup'

param location string
param acrId string
param blobStorageId string
param fileStorageId string
param ecommercePrivateEndpointSubnetId string
param internalPrivateEndpointSubnetId string
param acrDnsZoneId string
param blobDnsZoneId string
param fileDnsZoneId string

// ── ACR Private Endpoint (ecommerce spoke) ────────────────────────────────────

resource acrPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: 'pep-acr-ecommerce-uks'
  location: location
  properties: {
    subnet: { id: ecommercePrivateEndpointSubnetId }
    privateLinkServiceConnections: [
      {
        name: 'pep-acr-connection'
        properties: {
          privateLinkServiceId: acrId
          groupIds: ['registry']
        }
      }
    ]
  }
}

resource acrDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: acrPrivateEndpoint
  name: 'acr-dns-zone-group'
  properties: {
    privateDnsZoneConfigs: [
      { name: 'privatelink-azurecr-io', properties: { privateDnsZoneId: acrDnsZoneId } }
    ]
  }
}

// ── Blob Storage Private Endpoint (ecommerce spoke) ───────────────────────────

resource blobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: 'pep-blob-ecommerce-uks'
  location: location
  properties: {
    subnet: { id: ecommercePrivateEndpointSubnetId }
    privateLinkServiceConnections: [
      {
        name: 'pep-blob-connection'
        properties: {
          privateLinkServiceId: blobStorageId
          groupIds: ['blob']
        }
      }
    ]
  }
}

resource blobDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: blobPrivateEndpoint
  name: 'blob-dns-zone-group'
  properties: {
    privateDnsZoneConfigs: [
      { name: 'privatelink-blob-core-windows-net', properties: { privateDnsZoneId: blobDnsZoneId } }
    ]
  }
}

// ── Finance File Share Private Endpoint (internal spoke) ──────────────────────

resource filePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: 'pep-file-internal-uks'
  location: location
  properties: {
    subnet: { id: internalPrivateEndpointSubnetId }
    privateLinkServiceConnections: [
      {
        name: 'pep-file-connection'
        properties: {
          privateLinkServiceId: fileStorageId
          groupIds: ['file']
        }
      }
    ]
  }
}

resource fileDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: filePrivateEndpoint
  name: 'file-dns-zone-group'
  properties: {
    privateDnsZoneConfigs: [
      { name: 'privatelink-file-core-windows-net', properties: { privateDnsZoneId: fileDnsZoneId } }
    ]
  }
}
