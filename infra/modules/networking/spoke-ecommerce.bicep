targetScope = 'resourceGroup'

param location string

// ── NSGs ──────────────────────────────────────────────────────────────────────

resource appGatewayNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-appgateway-ecommerce-uks'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpInbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'AllowHttpsInbound'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'GatewayManager'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '65200-65535'
        }
      }
      {
        name: 'AllowAppGatewayToAppService'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '10.0.34.0/26'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

// ── VNet ──────────────────────────────────────────────────────────────────────

resource ecommerceVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-meridian-ecommerce-uks'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.32.0/20']
    }
    subnets: [
      {
        name: 'snet-appgateway-ecommerce-uks'
        properties: {
          addressPrefix: '10.0.32.0/26'
          networkSecurityGroup: { id: appGatewayNsg.id }
        }
      }
      {
        name: 'snet-containerapps-ecommerce-uks'
        properties: {
          addressPrefix: '10.0.33.0/24' // 10.0.33.0 – 10.0.33.255
        }
      }
      {
        name: 'snet-appservice-ecommerce-uks'
        properties: {
          addressPrefix: '10.0.34.0/26' // 10.0.34.0 – 10.0.34.63
          delegations: [
            {
              name: 'appServiceDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'snet-privateendpoints-ecommerce-uks'
        properties: {
          addressPrefix: '10.0.35.0/24' // 10.0.35.0 – 10.0.35.255
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// ── Application Gateway — blocked on Free Trial ────────────────────────────────
// Correct design: Standard_v2 SKU with WAF_v2, public IP, routing to Container Apps on port 8080
// Uncomment after upgrading to PAYG
//
// resource appGatewayPip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
//   name: 'pip-appgw-ecommerce-uks'
//   location: location
//   sku: { name: 'Standard' }
//   properties: { publicIPAllocationMethod: 'Static' }
// }
//
// resource appGateway 'Microsoft.Network/applicationGateways@2023-09-01' = {
//   name: 'agw-meridian-ecommerce-uks'
//   location: location
//   properties: {
//     sku: { name: 'WAF_v2', tier: 'WAF_v2', capacity: 1 }
//     gatewayIPConfigurations: [{ name: 'ipconfig', properties: { subnet: { id: '${ecommerceVnet.id}/subnets/snet-appgateway-ecommerce-uks' } } }]
//     frontendIPConfigurations: [{ name: 'frontend', properties: { publicIPAddress: { id: appGatewayPip.id } } }]
//     frontendPorts: [{ name: 'port443', properties: { port: 443 } }]
//     backendAddressPools: [{ name: 'catalogue-api-pool' }]
//     backendHttpSettingsCollection: [{ name: 'http-settings', properties: { port: 8080, protocol: 'Http', requestTimeout: 30 } }]
//     httpListeners: [{ name: 'https-listener', properties: { frontendIPConfiguration: { id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', 'agw-meridian-ecommerce-uks', 'frontend') }, frontendPort: { id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', 'agw-meridian-ecommerce-uks', 'port443') }, protocol: 'Https' } }]
//     requestRoutingRules: [{ name: 'default-rule', properties: { ruleType: 'Basic', priority: 100, httpListener: { id: resourceId('Microsoft.Network/applicationGateways/httpListeners', 'agw-meridian-ecommerce-uks', 'https-listener') }, backendAddressPool: { id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', 'agw-meridian-ecommerce-uks', 'catalogue-api-pool') }, backendHttpSettings: { id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'agw-meridian-ecommerce-uks', 'http-settings') } } }]
//     webApplicationFirewallConfiguration: { enabled: true, firewallMode: 'Prevention', ruleSetType: 'OWASP', ruleSetVersion: '3.2' }
//   }
// }

output ecommerceVnetId string = ecommerceVnet.id
output ecommerceVnetName string = ecommerceVnet.name
output containerAppsSubnetId string = '${ecommerceVnet.id}/subnets/snet-containerapps-ecommerce-uks'
output appServiceSubnetId string = '${ecommerceVnet.id}/subnets/snet-appservice-ecommerce-uks'
output privateEndpointSubnetId string = '${ecommerceVnet.id}/subnets/snet-privateendpoints-ecommerce-uks'
