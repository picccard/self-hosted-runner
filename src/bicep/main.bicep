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

@description('The container to deploy in the Container App')
param parAcaContainer typContainer

@description('The revision suffix for the Container App')
param parAcaRevisionSuffix string

@description('The minimum number of replicas for the Container App')
param parAcaScaleMinReplicas int

@description('The maximum number of replicas for the Container App')
param parAcaScaleMaxReplicas int

@description('The name of the Key Vault')
param parKvName string

@description('The GitHub repository owner')
param parGitHubRepoOwner string

@description('The name of the GitHub repository to install the self-hosted runner into')
param parGitHubRepoName string

@description('The GitHub Access Token with permission to fetch registration-token')
@secure()
param parGitHubAccessToken string

var varSecretNameGitHubAccessToken = 'github-accesstoken' // A value must consist of lower case alphanumeric characters, '-', and must start and end with an alphanumeric character. The length must not be more than 253 characters.

resource rg  'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: parResourceGroupName
  location: parLocation
}

module acaUami 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.2' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-aca-uami'
  params: {
    name: 'id-${parAcaName}'
  }
}

module acr 'br/public:avm/res/container-registry/registry:0.3.1' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-acr'
  params: {
    name: parAcrName
    roleAssignments: [
      {
        principalId: acaUami.outputs.principalId
        roleDefinitionIdOrName: 'AcrPull'
      }
    ]
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
    secrets: {
      secureList: [
        {
          name: varSecretNameGitHubAccessToken
          keyVaultUrl: '${kv.outputs.uri}secrets/${varSecretNameGitHubAccessToken}' // kv.outputs.uri when aca uses systemassigned-managedid -> The expression is involved in a cycle ("aca" -> "kv").
          identity: acaUami.outputs.resourceId // system assigned managed id -> 'system'
        }
      ]
    }
    registries: [
      {
        server: acr.outputs.loginServer
        identity: acaUami.outputs.resourceId
      }
    ]
    containers: [
      union(
        parAcaContainer,
        {
          env: [
            { name: 'ACCESS_TOKEN', secretRef: varSecretNameGitHubAccessToken }
            { name: 'OWNER', value: parGitHubRepoOwner }
            { name: 'REPO', value: parGitHubRepoName }
          ]
        }
      )
    ]
    revisionSuffix: parAcaRevisionSuffix
    scaleMinReplicas: parAcaScaleMinReplicas
    scaleMaxReplicas: parAcaScaleMaxReplicas
    ingressExternal: false
    managedIdentities: {
      userAssignedResourceIds: [acaUami.outputs.resourceId]
    }
  }
}

module kv 'br/public:avm/res/key-vault/vault:0.6.2' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-kv'
  params: {
    name: parKvName
    sku: 'standard'
    enablePurgeProtection: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    // enableVaultForDeployment: true
    publicNetworkAccess: 'Enabled'
    secrets: [
      {
        name: varSecretNameGitHubAccessToken
        value: parGitHubAccessToken
      }
    ]
    roleAssignments: [
      {
        principalId: acaUami.outputs.principalId
        roleDefinitionIdOrName: 'Key Vault Secrets User'
      }
    ]
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
