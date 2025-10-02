
param resourceGroupName string = 'RG1'

module RG1 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: resourceGroupName
  scope: subscription()
  params: {
    name: resourceGroupName
  }
}

var rgScope = resourceGroup(RG1.outputs.resourceId)

module hubVNet 'br/public:avm/res/network/virtual-network:0.7.1' = {
  name: 'hub-vnet'
  scope: rgScope
  params: {
    name: 'hub-vnet'
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: '10.0.0.0/26'
      }
    ]
  }
}

module appVNet 'br/public:avm/res/network/virtual-network:0.7.1' = {
  name: 'app-vnet'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'app-vnet'
    addressPrefixes: [
      '10.1.0.0/16'
    ]
    subnets: [
      {
        name: 'frontend-subnet'
        addressPrefix: '10.1.0.0/24'
      }
      {
        name: 'backend-subnet'
        addressPrefix: '10.1.1.0/24'
      }
    ]
    peerings: [
      {
        name: 'app-to-hub-vnet-peering'
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'hub-to-app-vnet-peering'
        remoteVirtualNetworkResourceId: hubVNet.outputs.resourceId
        useRemoteGateways: false
      }
    ]
  }
}
