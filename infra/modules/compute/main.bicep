targetScope = 'subscription'

// param vmAdminUsername string
// @secure()
// param vmAdminPassword string

// UK South has physical capacity restrictions on all general purpose and burstable SKUs for this subscription.
// UK West satisfies the NFR (data must remain in UK regions) and has available capacity.
// param vmLocation string = 'ukwest'

// ── Deployment blocked on Free Trial subscription ─────────────────────────────
// The design below is correct and exam-valid. Deployment is not possible because:
//   - Free Trial subscriptions restrict D-series and most B-series SKUs via NotAvailableForSubscription
//   - UK South has physical capacity constraints deprioritising trial accounts
//   - UK West was attempted as a fallback (satisfies UK data residency NFR) but hits the same subscription restrictions
//   - Only FX-series (compute-optimised, expensive) and very small B-series (insufficient for Windows Server) are unrestricted
// Resolution: upgrade subscription to Pay As You Go — credit carries over, SKU restrictions are lifted immediately.
// Uncomment modules below after upgrading.

// module network './network.bicep' = {
//   name: 'compute-network'
//   scope: resourceGroup('rg-meridian-prod-uks')
//   params: {
//     location: vmLocation
//   }
// }

// module vm './vm.bicep' = {
//   name: 'compute-vm'
//   scope: resourceGroup('rg-meridian-prod-uks')
//   params: {
//     location: vmLocation
//     subnetId: network.outputs.subnetId
//     adminUsername: vmAdminUsername
//     adminPassword: vmAdminPassword
//   }
// }

// module backup './backup.bicep' = {
//   name: 'compute-backup'
//   scope: resourceGroup('rg-meridian-prod-uks')
//   params: {
//     location: vmLocation
//     vmId: vm.outputs.vmId
//     vmName: vm.outputs.vmName
//     financeStorageAccountName: 'stmeridianfinanceuks'
//   }
// }
