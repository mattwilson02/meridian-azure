targetScope = 'resourceGroup'

param location string

// ── NSGs ──────────────────────────────────────────────────────────────────────

resource bastionNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-bastion-hub-uks'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          priority: 100
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
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'GatewayManager'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInbound'
        properties: {
          priority: 130
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: ['8080', '5701']
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Allow'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: ['22', '3389']
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          priority: 110
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureCloud'
          destinationPortRange: '443'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutbound'
        properties: {
          priority: 120
          direction: 'Outbound'
          access: 'Allow'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: ['8080', '5701']
        }
      }
    ]
  }
}

// ── VNet ──────────────────────────────────────────────────────────────────────

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-meridian-hub-uks'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/20']
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.0.0/26'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.64/27' // 10.0.0.64 – 10.0.0.95
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.0.128/26' // 10.0.0.128 – 10.0.0.191
        }
      }
    ]
  }
}

// ── Bastion ───────────────────────────────────────────────────────────────────

resource bastionPip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'pip-bastion-hub-uks'
  location: location
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static' }
}

resource bastion 'Microsoft.Network/bastionHosts@2023-09-01' = {
  name: 'bas-meridian-hub-uks'
  location: location
  sku: { name: 'Basic' }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: '${hubVnet.id}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: bastionPip.id
          }
        }
      }
    ]
  }
}

// ── Azure Firewall — blocked on Free Trial (cost ~£700/month) ─────────────────
// Correct design: Azure Firewall Standard in AzureFirewallSubnet, inspecting all spoke traffic
// Uncomment after upgrading to PAYG and if budget allows — consider Azure Firewall Basic SKU (~£300/month)
//
// resource firewallPip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
//   name: 'pip-firewall-hub-uks'
//   location: location
//   sku: { name: 'Standard' }
//   properties: { publicIPAllocationMethod: 'Static' }
// }
//
// resource firewall 'Microsoft.Network/azureFirewalls@2023-09-01' = {
//   name: 'afw-meridian-hub-uks'
//   location: location
//   sku: { name: 'AZFW_VNet', tier: 'Standard' }
//   properties: {
//     ipConfigurations: [{ name: 'ipconfig', properties: { subnet: { id: '${hubVnet.id}/subnets/AzureFirewallSubnet' }, publicIPAddress: { id: firewallPip.id } } }]
//   }
// }

// ── VPN Gateway — blocked on Free Trial (cost ~£100/month, 30-45 min to provision) ──
// Correct design: VpnGw1 SKU in GatewaySubnet, site-to-site tunnels to London/Manchester/Edinburgh
// Uncomment after upgrading to PAYG
//
// resource vpnGatewayPip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
//   name: 'pip-vpngw-hub-uks'
//   location: location
//   sku: { name: 'Standard' }
//   properties: { publicIPAllocationMethod: 'Static' }
// }
//
// resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
//   name: 'vpng-meridian-hub-uks'
//   location: location
//   properties: {
//     gatewayType: 'Vpn'
//     vpnType: 'RouteBased'
//     sku: { name: 'VpnGw1', tier: 'VpnGw1' }
//     ipConfigurations: [{ name: 'ipconfig', properties: { subnet: { id: '${hubVnet.id}/subnets/GatewaySubnet' }, publicIPAddress: { id: vpnGatewayPip.id } } }]
//   }
// }

output hubVnetId string = hubVnet.id
output hubVnetName string = hubVnet.name
output bastionSubnetId string = '${hubVnet.id}/subnets/AzureBastionSubnet'
