<properties
    pageTitle="Azure Stack is showing wrong node status"
    description="Azure Stack showing node status permanent as adding"
    service="microsoft.azurestack"
    resource="azurestack"
    authors="troettinger"
    ms.author="thoroet"
    displayOrder=""
    selfHelpType="generic"
    supportTopicIds=""
    resourceTags=""
    productPesIds="16226"
    cloudEnvironments="public"
    articleId="azurestack-operator-nodestatus"
/>

# Azure Stack is showing wrong node status

Azure Stack is showing the operational node status as “Adding” after an operation like drain, resume, repair, shutdown or start was executed.
This can happen when the Fabric Resource Provider Role cache did not refresh after an operation. 

Applies to: Azure Stack build 1808, 1809 and 1811

## **Recommended Steps**

Before applying the follwing steps ensure that no opeartion is currently in progress. (Update endpoint to match your environment)

1. Open PowerShell and add your Azure Stack environment. (This requires Azure Stack PowerShell to be installed on your computer)


 ```powershell
Add-AzureRmEnvironment -Name AzureStack -ARMEndpoint https://adminmanagement.local.azurestack.external
Add-AzureRmAccount -Environment AzureStack
```
*****

2. Run the following command to restart the Fabric Resource Provider Role.

```powershell
Restart-AzsInfrastructureRole -Name FabricResourceProvider
```
*****

3. Validate the operational status of the impacted Scale Unit node changed to running. You can use the Admin Portal or the below PowerShell command:
```powershell
Get-AzsScaleUnitNode |ft name,scaleunitnodestatus,powerstate
```
*****

4. If the node operational status is still shown as “Adding” continue to open a support incident.


## **Recommended Documents**

- [Install Azure Stack PowerShell](https://docs.microsoft.com/azure-stack/operator/azure-stack-powershell-install)
- [Monitor Add node operations](https://docs.microsoft.com/azure-stack/operator/azure-stack-add-scale-node#monitor-add-node-operations)