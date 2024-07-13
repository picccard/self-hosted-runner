targetScope = 'subscription'

@description('The location to deploy the resources to')
param parLocation string

@description('The name of the resource group')
param parResourceGroupName string

@description('The name of the User Assigned Managed Identity to create')
param parUamiName string

@description('''
The OIDC subjects to use for the federated identity credentials:
- environment: repo:<orgName/repoName>:environment:environmentName
- branch: repo:<orgName/repoName>:ref:refs/heads/branchName
- tag: repo:<orgName/repoName>:ref:refs/tags/tagName
- pull requests: repo:<orgName/repoName>:pull_request
''')
param parGithubOidcSubs string[]


resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: parResourceGroupName
  location: parLocation
}



module uami 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.2' = {
  name: '${uniqueString(deployment().name, parLocation)}-uami'
  scope: rg
  params: {
    name: parUamiName
    federatedIdentityCredentials: [
      for (sub, index) in parGithubOidcSubs : {
        name: replace(replace(sub, '/', '-'), ':','-') // replace / and : with -
        audiences: ['api://AzureADTokenExchange']
        issuer: 'https://token.actions.githubusercontent.com'
        subject: sub
      }
    ]
  }
}

output uamiClientId string = uami.outputs.clientId
