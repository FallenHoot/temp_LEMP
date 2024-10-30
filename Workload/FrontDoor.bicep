targetScope = 'resourceGroup'

// Global Parameters
param identifier string = 'lab1'
param environmentName string = 'Prod'
param solutionName string = '${identifier}${uniqueString(resourceGroup().id)}'
param WorkloadResourceGroup string = 'test'

// Front Door
param oneFrontDoorName string = 'fd-${solutionName}'
param oneFrontDoorBackendPoolName string = 'fdBackendPool'
param oneFrontDoorFrontendEndpointName string = 'fdFrontendEndpoint'

// Private DNS Zone
param onePrivateDnsZoneName string = 'npdz${identifier}.com'


module oneFrontDoor 'br/public:avm/res/network/front-door:0.3.1' = {
  name: 'frontDoorDeployment'
  params: {
    // Required parameters
    backendPools: [
      {
        name: oneFrontDoorBackendPoolName
        properties: {
          backends: [
            {
              address: 'biceptest.local'
              backendHostHeader: 'backendAddress'
              enabledState: 'Enabled'
              httpPort: 80
              httpsPort: 443
              priority: 1
              privateLinkAlias: ''
              privateLinkApprovalMessage: ''
              privateLinkLocation: ''
              weight: 50
            }
          ]
          HealthProbeSettings: {
            id: '<id>'
          }
          LoadBalancingSettings: {
            id: '<id>'
          }
        }
      }
    ]
    frontendEndpoints: [
      {
        name: oneFrontDoorFrontendEndpointName
        properties: {
          hostName: '<hostName>'
          sessionAffinityEnabledState: 'Disabled'
          sessionAffinityTtlSeconds: 60
        }
      }
    ]
    healthProbeSettings: [
      {
        name: 'heathProbe'
        properties: {
          enabledState: 'Enabled'
          healthProbeMethod: 'HEAD'
          intervalInSeconds: 60
          path: '/healthz'
          protocol: 'Https'
        }
      }
    ]
    loadBalancingSettings: [
      {
        name: 'loadBalancer'
        properties: {
          additionalLatencyMilliseconds: 0
          sampleSize: 50
          successfulSamplesRequired: 1
        }
      }
    ]
    name: oneFrontDoorName
    routingRules: [
      {
        name: 'routingRule'
        properties: {
          acceptedProtocols: [
            'Http'
            'Https'
          ]
          enabledState: 'Enabled'
          frontendEndpoints: [
            {
              id: '<id>'
            }
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            backendPool: {
              id: '<id>'
            }
            forwardingProtocol: 'MatchRequest'
          }
        }
      }
    ]
    // Non-required parameters
    enforceCertificateNameCheck: 'Disabled'
    location: resourceGroup().location
    sendRecvTimeoutSeconds: 10
    tags: {
      Environment: environmentName
      'hidden-title': 'Front Door for LEMP'
      Role: 'DeploymentValidation'
    }
  }
}

module onePrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.6.0' = {
  name: 'privateDnsZoneDeployment'
  params: {
    // Required parameters
    name: onePrivateDnsZoneName
    // Non-required parameters
    location: 'global'
    lock: {
      kind: 'CanNotDelete'
      name: oneLockName
    }
    tags: {
      Environment: environmentName
      'hidden-title': 'DNS Zone for LEMP'
      Role: 'DeploymentValidation'
    }
  }
}
