// modules/container-app.bicep
@description('The name of the container app')
param name string

@description('The location of the container app')
param location string = resourceGroup().location

@description('The tags to apply to the container app')
param tags object = {}

@description('The name of the container app environment')
param containerAppEnvironmentName string

@description('The name of the container registry')
param containerRegistryName string

@description('The container image to deploy')
param containerImage string

@description('The target port for the container')
param targetPort int = 80

@description('Min replicas')
param minReplicas int = 1

@description('Max replicas')
param maxReplicas int = 10

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppEnvironmentName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: containerRegistryName
}

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
        transport: 'auto'
      }
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.listCredentials().username
          passwordSecretRef: 'registry-password'
        }
      ]
      secrets: [
        {
          name: 'registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'todoapi'
          image: containerImage
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
}

output name string = containerApp.name
output uri string = 'https://${containerApp.properties.configuration.ingress.fqdn}'