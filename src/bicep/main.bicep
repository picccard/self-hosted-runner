targetScope = 'subscription'

@description('The location to deploy the resources to')
param parLocation string

@description('The name of the resource group')
param parResourceGroupName string

@description('The name of the Azure Container Registry')
param parAcrName string

@description('The name of the Log Analytics Workspace')
param parLogWorkspaceName string

@description('The name of the Managed Environment')
param parManagedEnvironmentName string

@description('The name of the Container App')
param parAcaName string

@description('The containers to deploy in the Container App')
param parAcaContainers typContainer[]

@description('The minimum number of replicas for the Container App')
param parAcaScaleMinReplicas int

@description('The maximum number of replicas for the Container App')
param parAcaScaleMaxReplicas int

resource rg  'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: parResourceGroupName
  location: parLocation
}


module acr 'br/public:avm/res/container-registry/registry:0.3.1' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-acr'
  params: {
    name: parAcrName
  }
}

module log 'br/public:avm/res/operational-insights/workspace:0.4.0' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-log-workspace'
  params: {
    name: parLogWorkspaceName
  }
}

module managedEnv 'br/public:avm/res/app/managed-environment:0.5.2' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-managed-environment'
  params: {
    name: parManagedEnvironmentName
    logAnalyticsWorkspaceResourceId: log.outputs.resourceId
    zoneRedundant: false
  }
}

module aca 'br/public:avm/res/app/container-app:0.4.1' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-aca'
  params: {
    name: parAcaName
    environmentId: managedEnv.outputs.resourceId
    containers: parAcaContainers
    scaleMinReplicas: parAcaScaleMinReplicas
    scaleMaxReplicas: parAcaScaleMaxReplicas
  }
}

type typContainer = {
  name: string
  image: string
  resources: {
    cpu: string
    memory: string
  }
}
