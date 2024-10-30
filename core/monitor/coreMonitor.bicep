// Global Parameters
param identifier string = 'lab1'
param oneResourceLocation string = 'swedencentral'

// Log Analytics Workspace Parameters
param oneLogAnalyticsWorkspaceName string = 'law-${identifier}-${oneResourceLocation}'

// Application Insights Parameters
param oneAppInsightName string = 'appinsi-${identifier}-${oneResourceLocation}'

module oneLAW 'br/public:avm/res/operational-insights/workspace:0.7.1' = {
  scope: resourceGroup(oneWorkloadResourceGroup.name)
  name: 'workspaceDeployment'
  params: {
    // Required parameters
    name: oneLogAnalyticsWorkspaceName
    // Non-required parameters
    dailyQuotaGb: 10
    dataSources: [
      {
        eventLogName: 'Application'
        eventTypes: [
          {
            eventType: 'Error'
          }
          {
            eventType: 'Warning'
          }
          {
            eventType: 'Information'
          }
        ]
        kind: 'WindowsEvent'
        name: 'applicationEvent'
      }
      {
        counterName: '% Processor Time'
        instanceName: '*'
        intervalSeconds: 60
        kind: 'WindowsPerformanceCounter'
        name: 'windowsPerfCounter1'
        objectName: 'Processor'
      }
      {
        kind: 'IISLogs'
        name: 'sampleIISLog1'
        state: 'OnPremiseEnabled'
      }
      {
        kind: 'LinuxSyslog'
        name: 'sampleSyslog1'
        syslogName: 'kern'
        syslogSeverities: [
          {
            severity: 'emerg'
          }
          {
            severity: 'alert'
          }
          {
            severity: 'crit'
          }
          {
            severity: 'err'
          }
          {
            severity: 'warning'
          }
        ]
      }
      {
        kind: 'LinuxSyslogCollection'
        name: 'sampleSyslogCollection1'
        state: 'Enabled'
      }
      {
        instanceName: '*'
        intervalSeconds: 10
        kind: 'LinuxPerformanceObject'
        name: 'sampleLinuxPerf1'
        objectName: 'Logical Disk'
        syslogSeverities: [
          {
            counterName: '% Used Inodes'
          }
          {
            counterName: 'Free Megabytes'
          }
          {
            counterName: '% Used Space'
          }
          {
            counterName: 'Disk Transfers/sec'
          }
          {
            counterName: 'Disk Reads/sec'
          }
          {
            counterName: 'Disk Writes/sec'
          }
        ]
      }
      {
        kind: 'LinuxPerformanceCollection'
        name: 'sampleLinuxPerfCollection1'
        state: 'Enabled'
      }
    ]
    gallerySolutions: [
      {
        name: 'AzureAutomation'
        product: 'OMSGallery'
        publisher: 'Microsoft'
      }
    ]
    linkedStorageAccounts: [
      {
        name: 'Query'
        resourceId: oneStorageAccount.outputs.resourceId
      }
    ]
    location: oneResourceLocation
    managedIdentities: {
      systemAssigned: true
    }
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
    storageInsightsConfigs: [
      {
        storageAccountResourceId: oneStorageAccount.outputs.resourceId
        tables: [
          'LinuxsyslogVer2v0'
          'WADETWEventTable'
          'WADServiceFabric*EventTable'
          'WADWindowsEventLogsTable'
        ]
      }
    ]
    tags: {
      Environment: 'Prod'
      'hidden-title': 'law-prod-${identifier}-${oneResourceLocation}'
      Role: 'DeploymentValidation'
    }
    useResourcePermissions: true
  }
}

module oneAppInsight 'br/public:avm/res/insights/component:0.4.1' = {
  scope: resourceGroup(oneWorkloadResourceGroup.name)
  name: 'componentDeployment'
  params: {
    // Required parameters
    name: oneAppInsightName
    workspaceResourceId: oneLAW.outputs.resourceId
    // Non-required parameters
    location: oneResourceLocation
    tags: {
      Environment: 'Prod'
      'hidden-title': 'appInsight-prod-${identifier}-${oneResourceLocation}'
      Role: 'DeploymentValidation'
    }
  }
}
