targetScope = 'subscription'

@description('Budget start date — must be the first day of a month (yyyy-MM-dd).')
param startDate string

var alerts = {
  actual80: {
    enabled: true
    operator: 'GreaterThan'
    threshold: 80
    contactEmails: []
    contactRoles: ['Owner', 'Contributor']
    thresholdType: 'Actual'
  }
  actual100: {
    enabled: true
    operator: 'GreaterThan'
    threshold: 100
    contactEmails: []
    contactRoles: ['Owner', 'Contributor']
    thresholdType: 'Actual'
  }
}

// Study environment: amounts reduced to stay within free trial credit.
// Production Meridian Retail values: compute £800, storage £150, networking £300, total £1350.
resource computeBudget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: 'budget-meridian-compute'
  properties: {
    timePeriod: { startDate: startDate }
    timeGrain: 'Monthly'
    amount: 5
    category: 'Cost'
    filter: {
      dimensions: {
        name: 'ResourceType'
        operator: 'In'
        values: [
          'microsoft.compute/virtualmachines'
          'microsoft.web/serverfarms'
          'microsoft.app/containerapps'
          'microsoft.containerregistry/registries'
        ]
      }
    }
    notifications: alerts
  }
}

resource storageBudget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: 'budget-meridian-storage'
  properties: {
    timePeriod: { startDate: startDate }
    timeGrain: 'Monthly'
    amount: 2
    category: 'Cost'
    filter: {
      dimensions: {
        name: 'ResourceType'
        operator: 'In'
        values: [
          'microsoft.storage/storageaccounts'
        ]
      }
    }
    notifications: alerts
  }
}

resource networkingBudget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: 'budget-meridian-networking'
  properties: {
    timePeriod: { startDate: startDate }
    timeGrain: 'Monthly'
    amount: 3
    category: 'Cost'
    filter: {
      dimensions: {
        name: 'ResourceType'
        operator: 'In'
        values: [
          'microsoft.network/virtualnetworks'
          'microsoft.network/bastionhosts'
          'microsoft.network/loadbalancers'
          'microsoft.network/vpngateways'
          'microsoft.network/publicipaddresses'
        ]
      }
    }
    notifications: alerts
  }
}

resource totalBudget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: 'budget-meridian-total'
  properties: {
    timePeriod: { startDate: startDate }
    timeGrain: 'Monthly'
    amount: 10
    category: 'Cost'
    notifications: alerts
  }
}
