targetScope = 'subscription'

@description('The location to deploy the resources to')
param parLocation string

@description('The name of the resource group')
param parResourceGroupName string

@description('The name of the Azure Container Registry')
param parAcrName string

@description('The name of the Log Analytics Workspace')
param parLogWorkspaceName string

@description('The name of the Virtual Network for the Managed Environment')
param parManagedEnvironmentVnetName string

@description('The name of the subnet for the Managed Environment infrastructure')
param parManagedEnvironmentInfraSubnetName string

@description('The name of the Managed Environment')
param parManagedEnvironmentName string

@description('The name of the infrastructure resource group for the Managed Environment')
param parManagedEnvironmentInfraResourceGroupName string

@description('Whether to deploy the container an app or a job. Option \'skip\' to deploy prereqs only')
param parContainerDeployMethod 'apps' | 'jobs' | 'skip'

@description('The name of the Container Job')
param parAcjName string

@description('The name of the Container App')
param parAcaName string

@description('The container to deploy in the Container App or Job')
param parContainer typContainer

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

module vnet 'br/public:avm/res/network/virtual-network:0.1.8' = {
  name: '${uniqueString(deployment().name, parLocation)}-vnet'
  scope: rg
  params: {
    name: parManagedEnvironmentVnetName
    addressPrefixes: ['10.20.0.0/16']
    subnets: [
      {
        name: parManagedEnvironmentInfraSubnetName
        addressPrefix: '10.20.0.0/23' // // https://github.com/microsoft/azure-container-apps/issues/451
        // Consumption only (workloadProfiles: []) -> no snet delegations
        // infrastructureResourceGroup CAN'T be customized
        // Workload profiles (workloadProfiles: [{...}]) -> snet delegations required
        // infrastructureResourceGroup CAN be customized
        delegations: [
          {
            name: 'Microsoft.App.environments'
            properties: {
              serviceName: 'Microsoft.App/environments'
            }
          }
        ]
        serviceEndpoints: [
          { service: 'Microsoft.Storage' }
        ]
      }
    ]
  }
}

/*
https://learn.microsoft.com/en-us/azure/container-apps/networking?tabs=workload-profiles-env%2Cazure-cli#managed-resources
Consumption only:
1 public ip for egress
2 loadbalancers if internal, 1 loadbalancer if external
Workload profiles:
1 public ip for egress, plus 1 public ip for ingress if external
1 loadbalancer
*/
module managedEnv 'br/public:avm/res/app/managed-environment:0.5.2' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-managed-environment'
  params: {
    name: parManagedEnvironmentName
    logAnalyticsWorkspaceResourceId: log.outputs.resourceId
    infrastructureResourceGroupName: parManagedEnvironmentInfraResourceGroupName
    infrastructureSubnetId: first(vnet.outputs.subnetResourceIds)
    internal: true
    zoneRedundant: false
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

module aca 'br/public:avm/res/app/container-app:0.7.0' = if (parContainerDeployMethod == 'apps') {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-aca'
  params: {
    name: parAcaName
    environmentResourceId: managedEnv.outputs.resourceId
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
        parContainer,
        {
          env: [
            { name: 'OWNER', value: parGitHubRepoOwner }
            { name: 'REPO', value: parGitHubRepoName }
            { name: 'ACCESS_TOKEN', secretRef: varSecretNameGitHubAccessToken }
            { name: 'RUNNER_NAME_PREFIX', value: 'self-hosted-runner' }
            { name: 'APPSETTING_WEBSITE_SITE_NAME', value: 'azcli-managed-identity-endpoint-workaround' } // https://github.com/Azure/azure-cli/issues/22677
          ]
        }
      )
    ]
    revisionSuffix: parAcaRevisionSuffix
    scaleMinReplicas: parAcaScaleMinReplicas
    scaleMaxReplicas: parAcaScaleMaxReplicas
    disableIngress: true
    managedIdentities: {
      userAssignedResourceIds: [acaUami.outputs.resourceId]
    }
  }
}

module acj 'br/public:avm/res/app/job:0.3.0' = if (parContainerDeployMethod == 'jobs') {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-acj'
  params: {
    name: parAcjName
    environmentResourceId: managedEnv.outputs.resourceId
    containers: [
      union(
        parContainer,
        {
          env: [
            { name: 'OWNER', value: parGitHubRepoOwner }
            { name: 'REPO', value: parGitHubRepoName }
            { name: 'ACCESS_TOKEN', secretRef: varSecretNameGitHubAccessToken }
            { name: 'RUNNER_NAME_PREFIX', value: 'self-hosted-runner' }
            { name: 'APPSETTING_WEBSITE_SITE_NAME', value: 'azcli-managed-identity-endpoint-workaround' } // https://github.com/Azure/azure-cli/issues/22677
          ]
        }
      )
    ]
    secrets: [
      {
        name: varSecretNameGitHubAccessToken
        keyVaultUrl: '${kv.outputs.uri}secrets/${varSecretNameGitHubAccessToken}' // kv.outputs.uri when aca uses systemassigned-managedid -> The expression is involved in a cycle ("aca" -> "kv").
        identity: acaUami.outputs.resourceId // system assigned managed id -> 'system'
      }
    ]
    registries: [
      {
        server: acr.outputs.loginServer
        identity: acaUami.outputs.resourceId
      }
    ]
    triggerType: 'Event'
    eventTriggerConfig: {
      scale: {
        rules: [
          {
            name: 'github-runner-scaling-rule'
            type: 'github-runner'
            auth: [
              {
                triggerParameter: 'personalAccessToken'
                secretRef: varSecretNameGitHubAccessToken
              }
            ]
            metadata: {
              githubApiURL: 'https://api.github.com'
              runnerScope: 'repo' // org (organisation) | ent (enterprise) | repo (repository)
              owner: parGitHubRepoOwner
              repos: parGitHubRepoName
            }
          }
        ]
      }
    }
    managedIdentities: {
      userAssignedResourceIds:[acaUami.outputs.resourceId]
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
