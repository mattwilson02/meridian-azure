targetScope = 'subscription'

param location string

module prodAssets './blob-storage.bicep' = {
  name: 'storage-assets-prod'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    storageAccountName: 'stmeridianassetsuks'
    location: location
    environmentValue: 'prod'
    accessTier: 'Hot'
    skuName: 'Standard_GRS'
  }
}

module nonprodAssets './blob-storage.bicep' = {
  name: 'storage-assets-nonprod'
  scope: resourceGroup('rg-meridian-nonprod-uks')
  params: {
    storageAccountName: 'stmeridiannonproduks'
    location: location
    environmentValue: 'nonprod'
    accessTier: 'Cool'
    skuName: 'Standard_LRS'
  }
}

module financeFileShare './file-share.bicep' = {
  name: 'storage-fileshare-finance'
  scope: resourceGroup('rg-meridian-prod-uks')
  params: {
    location: location
  }
}

output prodBlobStorageId string = prodAssets.outputs.storageAccountId
output prodBlobStorageName string = prodAssets.outputs.storageAccountName
output fileStorageId string = financeFileShare.outputs.storageAccountId
output fileStorageName string = financeFileShare.outputs.storageAccountName
output nonprodBlobStorageName string = nonprodAssets.outputs.storageAccountName
