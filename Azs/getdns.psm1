

# Copyright (c) Microsoft Corporation. All rights reserved.
# See LICENSE.txt in the project root for license information. 

<#
 
.SYNOPSIS 
 
Get DNS Server IP for Azure Stack Hub

 
.DESCRIPTION 
 
Calls ARM to get ERCS IP
Opens Remote Session to ERCS
Collect Azure Sdtack HUB Stamp information
Returns DNS IP


.PARAMETER $Region
Specify the Azure Stack Hub Region

.PARAMETER $Domain
Specify the Azure Stack Hub external Domain

.Example
$cred=get-credential
Get-DnsIP -Region local -Domain azurestack.external -PEPCredential $cred
#>

function Get-DnsIP {

Param(  
[string] $Region,
[string] $Domain,
[ValidateNotNull()]
[System.Management.Automation.PSCredential]$PEPCredential
)


Add-AzureRmEnvironment -name Admin -ARMEndpoint https://adminmanagement.$Region.$Domain |Out-Null
Add-AzureRmAccount -Environment Admin |out-null

$location=Get-AzsInfrastructureLocation -Location $Region
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $location.pepipaddresses[0] -force

$pep = New-PSSession -ComputerName $location.pepipaddresses[0] -ConfigurationName PrivilegedEndpoint -Credential $PEPCredential -SessionOption (New-PSSessionOption -Culture en-US -UICulture en-US)
$info = Invoke-Command -Session $pep -ScriptBlock {get-azurestackstampinformation}
Remove-PSSession $pep
$info.ExternalDNSIPAddress01

}

Export-ModuleMember -Function * -Alias *
