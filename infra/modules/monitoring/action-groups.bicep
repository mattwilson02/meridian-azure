targetScope = 'resourceGroup'

param securityEmail string
param engineeringEmail string
param cloudOpsEmail string

resource agSecurity 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'ag-security-prod'
  location: 'global'
  tags: {
    environment: 'prod'
    owner: 'cloud-engineering'
    costCentre: 'it'
  }
  properties: {
    groupShortName: 'sec-prod'
    enabled: true
    emailReceivers: [
      {
        name: 'Security Team'
        emailAddress: securityEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

resource agEngineering 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'ag-engineering-prod'
  location: 'global'
  tags: {
    environment: 'prod'
    owner: 'cloud-engineering'
    costCentre: 'it'
  }
  properties: {
    groupShortName: 'eng-prod'
    enabled: true
    emailReceivers: [
      {
        name: 'Engineering Team'
        emailAddress: engineeringEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

resource agCloudOps 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'ag-cloudops-prod'
  location: 'global'
  tags: {
    environment: 'prod'
    owner: 'cloud-engineering'
    costCentre: 'it'
  }
  properties: {
    groupShortName: 'ops-prod'
    enabled: true
    emailReceivers: [
      {
        name: 'Cloud Ops Team'
        emailAddress: cloudOpsEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

output agSecurityId string = agSecurity.id
output agEngineeringId string = agEngineering.id
output agCloudOpsId string = agCloudOps.id
