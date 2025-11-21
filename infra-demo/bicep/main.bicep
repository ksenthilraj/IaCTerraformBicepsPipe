param rgName string = 'netconf-demo-rg'
param location string = 'southindia'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: toLower('${rgName}sa')[0..23]
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
  dependsOn: [
    rg
  ]
}

output resourceGroupName string = rg.name
output storageAccountName string = storage.name
