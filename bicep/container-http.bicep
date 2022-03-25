param containerAppName string
param location string
param containerAppsEnvName string
param containerImage string
param containerPort int
param isExternalIngress bool
param containerRegistry string
param containerRegistryUsername string
param env array = []
param minReplicas int
param secrets array

@secure()
param containerRegistryPassword string

resource cappsEnv 'Microsoft.Web/kubeEnvironments@2021-03-01' existing = {
  name: containerAppsEnvName
}

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: cappsEnv.id
    configuration: {
      secrets: secrets
      registries: [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: 'reg-password'
        }
      ]
      ingress: {
        external: isExternalIngress
        targetPort: containerPort
        transport: 'auto'
      }
      dapr: {
        enabled: true
        appPort: containerPort
        appProtocol: 'http'
        appId: containerAppName
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: containerAppName
          env: env
        }
      ]
      scale: {
        minReplicas: minReplicas
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
