@description('The name of the log analytics workspace')
param name string

@description('The location of the log analytics workspace')
param location string = resourceGroup().location

@description('The tags to apply to the log analytics workspace')
param tags object = {}

@description('The SKU of the log analytics workspace')
param sku string = 'PerGB2018'

@description('The retention period in days')
param retentionInDays int = 30

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
  }
}

output name string = logAnalyticsWorkspace.name