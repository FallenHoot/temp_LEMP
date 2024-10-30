targetScope = 'resourceGroup'

// Global Parameters
param identifier string = 'lab1'
param environmentName string = 'Prod'
param solutionName string = '${identifier}${uniqueString(resourceGroup().id)}'
param LockName string = 'LEMPLock'

// Output
param oCoreNetwork string

// Resource Group
param WorkloadLocation string = 'swedencentral'
param WorkloadresourceGroupName string = 'rg-${solutionName}'
param UserAssignedIdentityName string = 'mi${solutionName}'

// Network Parameters
// Public IP Address
param PublicIpAddressName string = 'pip-${solutionName}'

// Storage Account Parameters
// param StorageAccountName string = 'sa-${solutionName}'

// Virtual Machine Scale Set
param VMSSName string = 'vmss-${solutionName}'
param VMSSSize string = 'Standard_D8as_v5'
param VMSSLocalAdminUser string = 'localadmin'
@secure()
@description('Local Admin Password. Required for virtual machine')
param VMSSLocalAdminPassword string
param cloudInit string

module WorkloadResourceGroup 'br/public:avm/res/resources/resource-group:0.3.0' = {
  scope: subscription()
  name: WorkloadresourceGroupName
  params: {
    location: WorkloadLocation
    name: WorkloadresourceGroupName
  }
}

module PublicIpAddress 'br/public:avm/res/network/public-ip-address:0.6.0' = {
  scope: resourceGroup(WorkloadResourceGroup.name)
  name: 'publicIpAddressDeployment${solutionName}'
  params: {
    // Required parameters
    name: PublicIpAddressName
    // Non-required parameters\
    location: resourceGroup().location
    lock: {
      kind: 'None'
      name: LockName
    }
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard'
    skuTier: 'Regional'
    tags: {
      Environment: environmentName
      'hidden-title': 'Public IP for VMSS'
      Role: 'DeploymentValidation'
    }
    zones: [
      1
      2
      3
    ]
  }
}

module UserAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  scope: resourceGroup(WorkloadResourceGroup.name)
  name: 'userAssignedIdentityDeployment${solutionName}'
  params: {
    // Required parameters
    name: UserAssignedIdentityName
    // Non-required parameters
    location: resourceGroup().location
    lock: {
      kind: 'None'
      name: LockName
    }
    tags: {
      Environment: environmentName
      'hidden-title': 'Managed Identity for LEMP'
      Role: 'DeploymentValidation'
    }
  }
}

module VirtualMachineScaleSet 'br/public:avm/res/compute/virtual-machine-scale-set:0.4.0' = {
  scope: resourceGroup(WorkloadResourceGroup.name)
  name: 'virtualMachineScaleSetDeployment${solutionName}'
  params: {
    // Required parameters
    adminUsername: VMSSLocalAdminUser
    imageReference: {
      offer: '0001-com-ubuntu-server-focal'
      publisher: 'Canonical'
      sku: '20_04-lts'
      version: 'latest'
    }
    name: VMSSName
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig1'
            properties: {
              publicIPAddressConfiguration: {
                name: PublicIpAddress.name
              }
              subnet: {
                id: oCoreNetwork
              }
            }
          }
        ]
        nicSuffix: '-nic01'
      }
    ]
    osDisk: {
      createOption: 'fromImage'
      diskSizeGB: '128'
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Linux'
    skuName: VMSSSize
    // Non-required parameters
    adminPassword: VMSSLocalAdminPassword
    customData: cloudInit
    extensionAntiMalwareConfig: {
      enabled: true
      settings: {
        AntimalwareEnabled: true
        Exclusions: {
          Extensions: '.log;.ldf'
          Paths: 'D:\\IISlogs;D:\\DatabaseLogs'
          Processes: 'mssence.svc'
        }
        RealtimeProtectinabled: true
        ScheduledScanSettings: {
          day: '7'
          isEnabled: 'true'
          scanType: 'Quick'
          time: '120'
        }
      }
    }
    extensionDependencyAgentConfig: {
      enabled: true
    }
    extensionDSCConfig: {
      enabled: true
    }
    extensionMonitoringAgentConfig: {
      enabled: true
    }
    extensionNetworkWatcherAgentConfig: {
      enabled: true
    }
    location: resourceGroup().location
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        UserAssignedIdentity.outputs.resourceId
      ]
    }
    skuCapacity: 2
    tags: {
      Environment: environmentName
      'hidden-title': 'vmss-for-LEMP'
      Role: 'DeploymentValidation'
    }
    upgradePolicyMode: 'Automatic'
    vmNamePrefix: 'vmsswinvm'
    vmPriority: 'Spot'
  }
}

/* module StorageAccount 'br/public:avm/res/storage/storage-account:0.9.1' = {
  scope: resourceGroup(WorkloadResourceGroup.name)
  name: 'storageAccountDeployment'
  params: {
    // Required parameters
    name: StorageAccountName
    // Non-required parameters
    allowBlobPublicAccess: false
    blobServices: {
      automaticSnapshotPolicyEnabled: true
      containerDeleteRetentionPolicyDays: 10
      containerDeleteRetentionPolicyEnabled: true
      containers: [
        {
          enableNfsV3AllSquash: true
          enableNfsV3RootSquash: true
          name: 'avdscripts'
          publicAccess: 'N'
        }
        {
          allowProtectedAppendWrites: false
          enableWORM: true
          metadata: {
            testKey: 'testValue'
          }
          name: 'archivecontainer'
          publicAccess: 'N'
          WORMRetention: 666
        }
      ]
      deleteRetentionPolicyDays: 9
      deleteRetentionPolicyEnabled: true
      lastAccessTimeTrackingPolicyEnabled: true
    }
    enableHierarchicalNamespace: true
    enableNfsV3: true
    enableSftp: true
    fileServices: {
      shares: [
        {
          accessTier: 'Hot'
          name: 'avdprofiles'
          shareQuota: 5120
        }
        {
          name: 'avdprofiles2'
          shareQuota: 102400
        }
      ]
    }
    largeFileSharesState: 'Enabled'
    localUsers: [
      {
        hasSharedKey: false
        hasSshKey: true
        hasSshPassword: false
        homeDirectory: 'avdscripts'
        name: 'testuser'
        permissionScopes: [
          {
            permissions: 'r'
            resourceName: 'avdscripts'
            service: 'blob'
          }
        ]
        storageAccountName: 'ssawaf001'
      }
    ]
    location: resourceGroup().location
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        UserAssignedIdentity.outputs.resourceId
      ]
    }
    managementPolicyRules: [
      {
        definition: {
          actions: {
            baseBlob: {
              delete: {
                daysAfterModificationGreaterThan: 30
              }
              tierToCool: {
                daysAfterLastAccessTimeGreaterThan: 5
              }
            }
          }
          filters: {
            blobIndexMatch: [
              {
                name: 'BlobIndex'
                op: '=='
                value: '1'
              }
            ]
            blobTypes: [
              'blockBlob'
            ]
            prefixMatch: [
              'sample-container/log'
            ]
          }
        }
        enabled: true
        name: 'FirstRule'
        type: 'Lifecycle'
      }
    ]
    queueServices: {
      queues: [
        {
          metadata: {
            key1: 'value1'
            key2: 'value2'
          }
          name: 'queue1'
        }
        {
          metadata: {}
          name: 'queue2'
        }
      ]
    }
    requireInfrastructureEncryption: true
    sasExpirationPeriod: '180.00:00:00'
    skuName: 'Standard_ZRS'
    tableServices: {
      tables: [
        {
          name: 'table1'
        }
        {
          name: 'table2'
        }
      ]
    }
    tags: {
      Environment: environmentName
      'hidden-title': 'Storage Account for LEMP'
      Role: 'DeploymentValidation'
    }
  }
}
 */
