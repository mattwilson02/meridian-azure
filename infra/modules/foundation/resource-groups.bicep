targetScope = 'subscription'

param location string

var prodRGName = 'rg-meridian-prod-uks'
var nonProdRGName = 'rg-meridian-nonprod-uks'

resource prodRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: prodRGName
  location: location
  tags: {
    environment: 'prod'
    owner: 'unset'
    costCentre: 'unset'
  }
}

resource nonProdRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: nonProdRGName
  location: location
  tags: {
    environment: 'nonprod'
    owner: 'unset'
    costCentre: 'unset'
  }
}

