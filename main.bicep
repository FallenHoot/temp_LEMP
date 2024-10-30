targetScope = 'resourceGroup'

param solutionName string = uniqueString(resourceGroup().id)

module coreNetwork_RegionOne 'core/network/coreNetwork.bicep' = {
  name: 'coreNetwork_Region${solutionName}'
  params: {
    environmentName: 'Prod'
    identifier: 'coreNetRegionOne'
    coreNetworkingLocation: 'swedencentral'
    coreAddressPrefixes: '172.16.1.0/24'
  }
}

// module coreNetwork_RegionTwo 'core/network/coreNetwork.bicep' = {
//   name: 'coreNetwork_RegionTwo${solutionName}'
//   params: {
//     environmentName: 'Prod'
//     identifier: 'coreNetRegionTwo'
//     coreNetworkingLocation: 'norwayeast'
//     coreAddressPrefixes: '172.16.2.0/24'
//   }
// }

module workloadRegionOne 'workload/workload.bicep' = {
  name: 'workloadRegionOne${solutionName}'
  dependsOn: [
    coreNetwork_RegionOne
  ]
  params: {
    identifier: 'workloadRegionOne'
    environmentName: 'Prod'
    WorkloadLocation: 'swedencentral'
    oCoreNetwork: coreNetwork_RegionOne.outputs.coreSubnet1
    VMSSSize: 'Standard_D8as_v5'
    VMSSLocalAdminUser: 'localadmin'
    VMSSLocalAdminPassword: 'Password123!'
    cloudInit: loadTextContent('./workload/vmss/cloud-init.yaml')
  }
}

// module workloadRegionTwo 'workload/workload.bicep' = {
//   name: 'workloadRegionTwo${solutionName}'
//   dependsOn: [
//     coreNetwork_RegionTwo
//   ]
//   params: {
//     identifier: 'workloadRegionTwo'
//     environmentName: 'Prod'
//     WorkloadLocation: 'norwayeast'
//     oCoreNetwork: coreNetwork_RegionTwo.outputs.coreSubnet1
//     VMSSSize: 'Standard_D8as_v5'
//     VMSSLocalAdminUser: 'localadmin'
//     VMSSLocalAdminPassword: 'Password123!'
//   }
// }

module workloadSQL 'workload/mySQL.bicep' = {
  name: 'workloadSQL${solutionName}'
  params: {
    SQLLocation: 'swedencentral'
    MySQLLocalAdminUser: 'localadmin'
    MySQLLocalAdminPassword: 'Password123!'
  }
}
