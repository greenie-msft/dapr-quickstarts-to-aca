param location string = resourceGroup().location
param uniqueSeed string = '${subscription().subscriptionId}-${resourceGroup().name}'
param uniqueSuffix string = 'daprcapps-${uniqueString(uniqueSeed)}'
param containerAppsEnvName string = 'cae-${uniqueSuffix}'
param logAnalyticsWorkspaceName string = 'log-${uniqueSuffix}'
param logAnalyticsLocation string = 'centralus'
param minReplicas int = 1
param checkoutImage string = ''
param orderProcessorImage string = ''
param containerRegistry string = ''
param containerRegistryUsername string = ''


@secure()
param containerRegistryPassword string

// Container Apps Environment
module containerAppsEnvModule '../../../../bicep/environment.bicep' = {
  name:'${deployment().name}--containerAppsEnv'
  params: {
    environmentName: containerAppsEnvName
    location: location
    logAnalyticsWorkspaceName: 'logs-${containerAppsEnvName}'
    logAnalyticsLocation: logAnalyticsLocation
  }
}

// Checkout Service
module checkoutServiceModule '../../../../bicep/container-http.bicep' = {
  name: '${deployment().name}--checkout-service'
   dependsOn: [
    containerAppsEnvModule
  ]
  params: {
    location: location
    containerAppName: 'checkout'
    containerPort: 3000
    isExternalIngress: false
    minReplicas: minReplicas
    containerRegistry: containerRegistry
    containerRegistryUsername: containerRegistryUsername
    containerRegistryPassword: containerRegistryPassword
    containerImage: checkoutImage
    secrets: [
      {
        name: 'docker-password'
        value: containerRegistryPassword
      }
    ]
  }
}


// Order Processor Service
module orderProcessorServiceModule '../../../../bicep/container-http.bicep' = {
  name: '${deployment().name}--order-processor-service'
   dependsOn: [
    containerAppsEnvModule
    checkoutServiceModule
  ]
  params: {
    location: location
    containerAppName: 'order-processor'
    containerImage: orderProcessorImage
    containerPort: 5001
    isExternalIngress: false
    minReplicas: minReplicas
    containerRegistry: containerRegistry
    containerRegistryUsername: containerRegistryUsername
    containerRegistryPassword: containerRegistryPassword
    secrets: [
      {
        name: 'docker-password'
        value: containerRegistryPassword
      }
    ]
  }
}
