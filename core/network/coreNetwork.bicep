targetScope = 'resourceGroup'

// Global Parameters
param environmentName string = 'Prod'
param identifier string = 'coreNWLab1'
param solutionName string = '${identifier}${uniqueString(resourceGroup().id)}'
param coreNetworkingLocation string = 'swedencentral'
param coreNetworkResourceGroupName string = 'rg-${solutionName}'

// Network Parameters
// Virtual Network
param vNetWorkloadName string = 'vnet-${solutionName}'
param coreAddressPrefixes string = '172.16.1.0/24'

@description('The preferred CIDR for the subnet. Default: 26')
param parSubnetCidr int = 26

@description('The amount of subnets to create. Default: 3')
param parAmountOfSubnets int = 3

var SubnetCalculations = [
  for i in range(0, parAmountOfSubnets): {
    name: 'sn-${i}'
    addressPrefix: cidrSubnet(coreAddressPrefixes, parSubnetCidr, i)
  }
]
// Network Security Group
param coreNetworkSecurityGroupName string = 'nsg-${solutionName}'

module coreNetworkResourceGroup 'br/public:avm/res/resources/resource-group:0.3.0' = {
  scope: subscription()
  name: coreNetworkResourceGroupName
  params: {
    location: coreNetworkingLocation
    name: coreNetworkResourceGroupName
  }
}

module coreNetworkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.0' = {
  scope: resourceGroup(coreNetworkResourceGroup.name)
  name: 'networkSecurityGroupDeployment${solutionName}'
  params: {
    // Required parameters
    name: coreNetworkSecurityGroupName
    // Non-required parameters
    location: coreNetworkingLocation
    
    securityRules: [
      {
        name: 'deny-hop-outbound'
        properties: {
          access: 'Deny'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          direction: 'Outbound'
          priority: 200
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
    ]
    tags: {
      Environment: environmentName
      'hidden-title': 'Core Network Security Group'
      Role: 'DeploymentValidation'
    }
  }
}

module corevNet 'br/public:avm/res/network/virtual-network:0.5.0' = {
  scope: resourceGroup(coreNetworkResourceGroup.name)
  name: 'virtualNetworkDeployment${solutionName}'
  params: {
    // Required parameters
    addressPrefixes: [
      coreAddressPrefixes
    ]
    name: vNetWorkloadName
    // Non-required parameters
    flowTimeoutInMinutes: 20
    location: coreNetworkingLocation
    subnets: SubnetCalculations
    tags: {
      Environment: environmentName
      'hidden-title': 'Core Network'
      Role: 'DeploymentValidation'
    }
  }
}
output corevNetName string = corevNet.outputs.name
output coreSubnet0 string = corevNet.outputs.subnetResourceIds[0]
output coreSubnet1 string = corevNet.outputs.subnetResourceIds[1]
output coreSubnet2 string = corevNet.outputs.subnetResourceIds[2]
