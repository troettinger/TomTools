$FQDN = Read-Host "Enter External FQDN"
$RegionName = Read-Host "Enter Azure Stack Region Name"
Add-AzureRmEnvironment -Name Admin -ARMEndpoint https://management.$regionname.$FQDN |out-null
Add-AzureRmAccount -Environment Admin|Out-Null


Get-AzureRmResourceProvider | `
  Select ProviderNamespace -Expand ResourceTypes | `
  Select * -Expand ApiVersions | `
  Select ProviderNamespace, ResourceTypeName, @{Name="ApiVersion"; Expression={$_}}
  