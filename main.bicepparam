using 'src/bicep/main.bicep'

param parLocation = 'norwayeast'
param parResourceGroupName = 'rg-gh-runners-001'

param parAcrName = 'eulano'

param parContainerDeployMethod = 'apps' // 'apps' | 'jobs' | 'skip'
param parLogWorkspaceName = 'log-gh-runners-001'
param parManagedEnvironmentName = 'env-gh-runners-001'

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

param parAcaRevisionSuffix = 'v1'
param parAcaScaleMinReplicas = 2
param parAcaScaleMaxReplicas = 2

param parKvName = 'kv-gh-runners-001'

param parGitHubRepoOwner = 'picccard'
param parGitHubRepoName = 'self-hosted-runner'
param parGitHubAccessToken = readEnvironmentVariable('GITHUB_ACCESS_TOKEN')
