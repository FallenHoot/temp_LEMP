using 'coreMonitor.bicep'

// Global Parameters
param identifier = 'lab1'
param oneResourceLocation = 'swedencentral'
// Log Analytics Workspace Parameters
param oneLogAnalyticsWorkspaceName = 'law-${identifier}-${oneResourceLocation}'

// Application Insights Parameters
param oneAppInsightName = 'appinsi-${identifier}-${oneResourceLocation}'
