@description('The name of the container registry')
param name string

@description('The location of the container registry')
param location string = resourceGroup().location

@description('The SKU of the container registry')
param sku string = 'Basic'

@description('The tags to apply to the container registry')
param tags object = {}

@description('Enable admin user')
param adminUserEnabled bool = true

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}

@description('The login server for the container registry')
output loginServer string = containerRegistry.properties.loginServer

@description('The name of the container registry')
output name string = containerRegistry.name