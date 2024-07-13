using 'src/bicep/prereq.bicep'

param parLocation = 'norwayeast'
param parResourceGroupName = 'rg-gh-runners-id-001'
param parUamiName = 'id-gh-runners-001'
param parGithubOidcSubs = ['repo:picccard/self-hosted-runner:ref:refs/heads/main']
