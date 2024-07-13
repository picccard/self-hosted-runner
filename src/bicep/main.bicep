targetScope = 'subscription'

@description('The location to deploy the resources to')
param parLocation string

@description('The name of the resource group')
param parResourceGroupName string

@description('The name of the Azure Container Registry')
param parAcrName string

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
