targetScope = 'resourceGroup'

// UDRs force spoke subnet traffic through the Azure Firewall in the hub.
// firewallPrivateIp should be set to the firewall's private IP once provisioned.
// Using a placeholder — update after Azure Firewall is deployed.
param firewallPrivateIp string = '10.0.0.4' // Azure assigns .4 as first usable IP in AzureFirewallSubnet

var defaultRoute = [
  {
    name: 'route-to-firewall'
    properties: {
      addressPrefix: '0.0.0.0/0'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: firewallPrivateIp
    }
  }
]

// ── Internal Spoke Route Tables ───────────────────────────────────────────────

resource udrVmSubnet 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'udr-vm-internal-uks'
  location: resourceGroup().location
  properties: { routes: defaultRoute }
}

resource udrPrivateEndpointsInternal 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'udr-privateendpoints-internal-uks'
  location: resourceGroup().location
  properties: { routes: defaultRoute }
}

// ── Ecommerce Spoke Route Tables ──────────────────────────────────────────────

resource udrAppGateway 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'udr-appgateway-ecommerce-uks'
  location: resourceGroup().location
  properties: { routes: defaultRoute }
}

resource udrContainerApps 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'udr-containerapps-ecommerce-uks'
  location: resourceGroup().location
  properties: { routes: defaultRoute }
}

resource udrAppService 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'udr-appservice-ecommerce-uks'
  location: resourceGroup().location
  properties: { routes: defaultRoute }
}

resource udrPrivateEndpointsEcommerce 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'udr-privateendpoints-ecommerce-uks'
  location: resourceGroup().location
  properties: { routes: defaultRoute }
}

output udrVmSubnetId string = udrVmSubnet.id
output udrPrivateEndpointsInternalId string = udrPrivateEndpointsInternal.id
output udrAppGatewayId string = udrAppGateway.id
output udrContainerAppsId string = udrContainerApps.id
output udrAppServiceId string = udrAppService.id
output udrPrivateEndpointsEcommerceId string = udrPrivateEndpointsEcommerce.id
