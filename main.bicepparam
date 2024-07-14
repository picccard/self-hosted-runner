using 'src/bicep/main.bicep'

param parLocation = 'norwayeast'
param parResourceGroupName = 'rg-gh-runners-001'

param parAcrName = 'eulano'

param parLogWorkspaceName = 'log-gh-runners-001'
param parManagedEnvironmentName = 'env-gh-runners-001'

param parAcaName = 'aca-gh-runners-001'
param parAcaContainer = {
  name: 'ghrunner'
  image: 'eulano.azurecr.io/ghrunner-linux:v0.1.0'
  resources: {
    cpu: '0.25'
    memory: '0.5Gi'
  }
}

param parAcaRevisionSuffix = 'v1'
param parAcaScaleMinReplicas = 0
param parAcaScaleMaxReplicas = 5

param parKvName = 'kv-gh-runners-001'

param parGithubRepoOwner = 'picccard'
param parGithubRepoName = 'self-hosted-runner'
param parGitHubPat = readEnvironmentVariable('GITHUB_PAT')
