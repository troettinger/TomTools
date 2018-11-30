$FQDN = Read-Host "Enter External FQDN"
$RegionName = Read-Host "Enter Azure Stack Region Name"
$TenantID = Read-Host "Enter TenantID"
$OfferName = Read-Host "Enter New Offer Name"
$PlanName = Read-Host "Enter New Plan Name"
$RGName = Read-Host "Enter New Resource Group Name"


#Add Environment & Authenticate
Add-AzureRmEnvironment -Name AzureStackAdmin -ARMEndpoint https://adminmanagement.$RegionName.$FQDN |Out-Null
Login-AzureRmAccount -Environment AzureStackAdmin -TenantId $TenantID |Out-Null

#Create Compute Quota
$ComputeQuota=New-AzsComputeQuota -Name IgniteCompute -CoresLimit 100 -AvailabilitySetCount 50 -VmScaleSetCount 50 -VirtualMachineCount 100

#Create Network Quota
$NetworkQuota=New-AzsNetworkQuota -Name IgniteNetwork -MaxNicsPerSubscription 100 -MaxPublicIpsPerSubscription 5 -MaxVirtualNetworkGatewaysPerSubscription 1 -MaxVirtualNetworkGatewayConnectionsPerSubscription 2 -MaxVnetsPerSubscription 50 -MaxSecurityGroupsPerSubscription 50 -MaxLoadBalancersPerSubscription 50

#Create Storage Quota
$StorageQuota=New-AzsStorageQuota -Name IgniteStorage -CapacityInGb 1024 -NumberOfStorageAccounts 10

#Get KeyVault Quota
$KeyVaultQuota=Get-AzsKeyVaultQuota

#Create new Plan & Assign Quotas
$quota=($ComputeQuota.id,$NetworkQuota.id,$StorageQuota.Id,$KeyVaultQuota.Id)
$ResoureGroup=New-AzureRmResourceGroup -Name $RGName -Location local
$Plan=New-AzsPlan -Name $PlanName -ResourceGroupName $ResoureGroup.ResourceGroupName -DisplayName IgniteDemoPlan -QuotaIds $quota

#Create Offer
$Offer=New-AzsOffer -Name $OfferName-DisplayName IgniteFreeDemo -ResourceGroupName $ResoureGroup.ResourceGroupName -BasePlanIds $plan.Id

#Make Offer Public
Set-AzsOffer -Name $offer.Name -State public -ResourceGroupName $ResoureGroup.ResourceGroupName


#Optinal - Create Subcription
#New-AzsUserSubscription -OfferId $Offer.Id -Owner thoroet@fabrikam.com -DisplayName MyFreeIgniteSubscription







