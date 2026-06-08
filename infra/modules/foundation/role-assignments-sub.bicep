targetScope = 'subscription'

param headOfFinanceGroupId string

var costManagementReaderRoleId = '72fafb9e-0641-4937-9268-a91bfd8191a3'

resource headOfFinanceCostReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, headOfFinanceGroupId, costManagementReaderRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', costManagementReaderRoleId)
    principalId: headOfFinanceGroupId
    principalType: 'Group'
  }
}
