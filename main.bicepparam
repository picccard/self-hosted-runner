using 'src/bicep/main.bicep'

param parLocation = 'norwayeast'
param parResourceGroupName = 'rg-gh-runners-001'

param parAcrName = 'eulano'

param parLogWorkspaceName = 'log-gh-runners-001'
param parManagedEnvironmentName = 'env-gh-runners-001'

param parAcaName = 'aca-gh-runners-001'
param parAcaImage = 'nginxdemos/hello:plain-text' // tag: latest | plain-text
