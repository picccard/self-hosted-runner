using 'src/bicep/main.bicep'

param parLocation = 'norwayeast'
param parResourceGroupName = 'rg-gh-runners-001'

param parAcrName = 'eulano'

param parContainerDeployMethod = 'jobs' // 'apps' | 'jobs' | 'skip'
param parLogWorkspaceName = 'log-gh-runners-001'
param parManagedEnvironmentVnetName = 'vnet-gh-runners-001'
param parManagedEnvironmentInfraSubnetName = 'snet-aca-env'
param parManagedEnvironmentInfraResourceGroupName = 'rg-gh-runners-env-infra-001'
param parManagedEnvironmentName = 'env-gh-runners-001'

/* only used for testing
param parTestVnetServiceEndpoint = {
  storageAccountName: 'st4runnertest001'
  containerName: 'testcontainer'
}*/

param parAcjName = 'acj-gh-runners-001'
param parAcaName = 'aca-gh-runners-001'
param parContainer = {
  name: 'ghrunner'
  image: 'eulano.azurecr.io/ghrunner-linux:v0.1.0'
  resources: {
    cpu: '0.25'
    memory: '0.5Gi'
  }
}

param parAcaRevisionSuffix = 'v1' // A revision name must consist of lower case alphanumeric characters or '-', start with an alphabetic character, and end with an alphanumeric character. The length of the revision name must not be more than a combined 54 characters with the container app name.
param parAcaScaleMinReplicas = 2
param parAcaScaleMaxReplicas = 2

param parKvName = 'kv-gh-runners-001'

param parGitHubRepoOwner = 'picccard'
param parGitHubRepoName = 'self-hosted-runner'
param parGitHubAccessToken = readEnvironmentVariable('GITHUB_ACCESS_TOKEN') // az.getSecret('<subscription-id>', '<rg-name>', '<key-vault-name>', '<secret-name>', '<secret-version>')
