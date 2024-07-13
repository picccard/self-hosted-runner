using 'src/bicep/main.bicep'

param parLocation = 'norwayeast'
param parResourceGroupName = 'rg-gh-runners-001'

param parAcrName = 'eulano'

param parLogWorkspaceName = 'log-gh-runners-001'
param parManagedEnvironmentName = 'env-gh-runners-001'

param parAcaName = 'aca-gh-runners-001'
param parAcaContainers = [
  {
    name: 'nginx'
    image: 'nginxdemos/hello:plain-text' // tag: latest | plain-text
    resources: {
      cpu: '0.25'
      memory: '0.5Gi'
    }
  }
]
