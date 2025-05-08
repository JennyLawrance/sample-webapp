// main.bicep - The main orchestration template
@description('The environment name. Default: dev')
param environmentName string = 'dev'

@description('The location for all resources. Default: app service resource group location')
param location string = resourceGroup().location

@description('Tags for all resources')
param tags object = {}

// Generate a unique name for the resources
@description('A unique suffix for names')
param resourceToken string = uniqueString(subscription().subscriptionId, resourceGroup().id)

// Container image reference
@description('The container image to deploy')
param containerImage string = ''

// List of required services
var services = {
  containerRegistry: {
    name: 'registry'
    shortName: 'acr'
  }
  containerApp: {
    name: 'todoapi'
    shortName: 'ca'
  }
  logAnalytics: {
    name: 'logAnalytics'
    shortName: 'log'
  }
  containerAppEnvironment: {
    name: 'appEnvironment'
    shortName: 'cae'
  }
}

// Name parameters based on azd conventions
var resourceNames = {
  containerRegistry: '${environmentName}${services.containerRegistry.shortName}${resourceToken}'
  containerApp: '${environmentName}${services.containerApp.shortName}${resourceToken}'
  logAnalytics: '${environmentName}${services.logAnalytics.shortName}${resourceToken}'
  containerAppEnvironment: '${environmentName}${services.containerAppEnvironment.shortName}${resourceToken}'
}

// Deploy the Container Registry
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'container-registry'
  params: {
    name: resourceNames.containerRegistry
    location: location
    tags: tags
  }
}

// Deploy the Log Analytics workspace
module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'log-analytics'
  params: {
    name: resourceNames.logAnalytics
    location: location
    tags: tags
  }
}

// Deploy the Container App Environment
module containerAppEnvironment 'modules/container-app-environment.bicep' = {
  name: 'container-app-environment'
  params: {
    name: resourceNames.containerAppEnvironment
    location: location
    tags: tags
    logAnalyticsWorkspaceName: logAnalytics.outputs.name
  }
}

// Deploy the Container App
module containerApp 'modules/container-app.bicep' = {
  name: 'container-app'
  params: {
    name: resourceNames.containerApp
    location: location
    tags: tags
    containerAppEnvironmentName: containerAppEnvironment.outputs.name
    containerImage: !empty(containerImage) ? containerImage : 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
    containerRegistryName: containerRegistry.outputs.name
    targetPort: 80
  }
}

// Output the important variables
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name
output AZURE_CONTAINER_APP_NAME string = containerApp.outputs.name
output AZURE_CONTAINER_APP_ENDPOINT string = containerApp.outputs.uri
