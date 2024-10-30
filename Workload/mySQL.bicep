targetScope = 'resourceGroup'

// Global Parameters
param identifier string = 'lab1'
param environmentName string = 'Prod'
param solutionName string = '${identifier}${uniqueString(resourceGroup().id)}'
param LockName string = 'LEMPLock'

// Resource Group
param sqlResourceGroupName string = 'rg-sql-${solutionName}'
param SQLLocation string = 'swedencentral'

// MySQL Flexible Server
param MySQLFlexibleServerName string = 'mysql${solutionName}'
param MySQLSKU string = 'Standard_D4ads_v5'
param MySQLLocalAdminUser string = 'localadmin'
@secure()
@description('Local Admin Password. Required for virtual machine')
param MySQLLocalAdminPassword string

module sqlResourceGroup 'br/public:avm/res/resources/resource-group:0.3.0' = {
  scope: subscription()
  name: sqlResourceGroupName
  params: {
    location: SQLLocation
    name: sqlResourceGroupName
  }
}

module MySQLFlexibleServer 'br/public:avm/res/db-for-my-sql/flexible-server:0.4.1' = {
  scope: resourceGroup(sqlResourceGroup.name)
  name: 'flexibleServerDeployment${solutionName}'
  params: {
    // Required parameters
    name: MySQLFlexibleServerName
    skuName: MySQLSKU
    tier: 'GeneralPurpose'
    // Non-required parameters
    administratorLogin: MySQLLocalAdminUser
    administratorLoginPassword: MySQLLocalAdminPassword
    highAvailability: 'ZoneRedundant'
    geoRedundantBackup: 'Disabled'
    location: resourceGroup().location
    lock: {
      kind: 'None'
      name: LockName
    }
    storageAutoGrow: 'Enabled'
    tags: {
      Environment: environmentName
      'hidden-title': 'MySQL for LEMP'
      Role: 'DeploymentValidation'
    }
  }
}
