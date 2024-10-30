# Check if running PowerShell 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
  Write-Host "You are not running PowerShell 7. Please install PowerShell 7 from https://aka.ms/powershell-release."
  return
}

# Check if the Az module is installed
if (-not (Get-Module -ListAvailable -Name Az)) {
  Write-Host "The Az module is not installed. Installing the Az module..."
  Install-Module -Name Az -AllowClobber -Force
} else {
  Write-Host "The Az module is already installed."
  
  # Check for the latest version of the Az module
  $currentVersion = (Get-Module -ListAvailable -Name Az).Version
  $latestVersion = (Find-Module -Name Az).Version
  
  if ($currentVersion -lt $latestVersion) {
    Write-Host "A newer version of the Az module is available: $latestVersion (current: $currentVersion)"
    $update = Read-Host "Do you want to update to the latest version? (y/n)"
    
    if ($update -eq 'y') {
      Write-Host "Updating the Az module to the latest version..."
      
      # Check if the module was installed using Install-Module
      $installedModule = Get-InstalledModule -Name Az -ErrorAction SilentlyContinue
      if ($null -eq $installedModule) {
        Write-Host "The Az module was not installed using Install-Module. Uninstalling the existing module..."
        $uninstallOrUpdate = Read-Host "Do you want to uninstall the existing module and reinstall it using Install-Module, or update it another way? (uninstall/update)"
      
      if ($uninstallOrUpdate -eq 'uninstall') {
        Write-Host "Uninstalling the existing module..."
        Uninstall-Module -Name Az -AllVersions -Force
        Write-Host "Reinstalling the Az module using Install-Module..."
        Install-Module -Name Az -AllowClobber -Force
      } else {
        Write-Host "Please update the Az module using your preferred method."
      }
    } else {
      Update-Module -Name Az -Force
    }
  } else {
      Write-Host "Continuing with the current version of the Az module."
    }
  } else {
    Write-Host "You are using the latest version of the Az module."
  }
}

# Import the Az module
Import-Module Az
Write-Host "Az module imported successfully."

# Ensure the user is logged in to Azure
if (-not (Get-AzContext)) {
    Write-Host "You are not logged in to Azure. Please log in."
    Connect-AzAccount
}

# Ensure the user is logged in to the selected tenant
Connect-AzAccount

# List of Azure regions
$regions = @(
    "eastus", "eastus2", "centralus", "northcentralus", "southcentralus",
    "westus", "westus2", "canadacentral", "canadaeast", "brazilsouth",
    "northeurope", "westeurope", "uksouth", "ukwest", "francecentral",
    "francesouth", "switzerlandnorth", "switzerlandwest", "germanywestcentral",
    "germanynorth", "norwayeast", "norwaywest", "swedencentral", "swedensouth",
    "uaenorth", "uaecentral", "japaneast", "japanwest", "australiaeast",
    "australiasoutheast", "australiacentral", "australiacentral2", "southeastasia",
    "eastasia", "koreacentral", "koreasouth", "southindia", "centralindia",
    "westindia", "chinaeast2", "chinanorth2"
)

# Display the list of regions and prompt the user to select one
$location = $regions | Out-GridView -Title "Select an Azure Region" -PassThru

if ($null -eq $location) {
    Write-Host "No region selected. Exiting..."
    return
}

Write-Host "Selected Azure region: $location"

# Bicep File Paths
$templateFile = "main.bicep"

# Deploy the Bicep template
New-AzSubscriptionDeployment `
  -Location $location `
  -TemplateFile $templateFile

New-AzDeployment -Location "sweden central" -TemplateFile "main.bicep"