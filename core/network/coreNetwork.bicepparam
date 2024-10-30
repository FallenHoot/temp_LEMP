using 'coreNetwork.bicep'

// Global Parameters
param environmentName  = 'Prod'
param identifier  = 'coreNWLab1'
param coreNetworkingLocation = 'swedencentral'

// Network Parameters
// Virtual Network
param oneAddressPrefixes = '172.16.1.0/24'
