# Secure Operator Role

## Sample script and role template that does create a new RBAC role with all permissions except to create or update user subscriptions

## Scenario

### Every user object that has Owner or Contributer permission to the deafult provider subscription can overwrite the owner of ANY user subscription.  This is by design for example to change the billing owner of a subscription when a user leaves your organization.  This is described here: https://docs.microsoft.com/en-us/azure-stack/operator/azure-stack-change-subscription-owner?view=azs-2002

## Best Practices

### - The Owner permissions to the deafult provider subscription should only be granded to a single user with a secure password and locked away.
### - Create custom roles with only permissions required for the day to day operations
### - Use strong passwords
### - Multi Factor authentication should be enabled for all users having access to the default provider subscription
### - When using Azure Active Directory use conditional access


## Samples


#### - Secure Operator Role grants the same permission as the Onwer Role except the permission to create or update any user subscription.

## How to use

### Requirements
#### - PowerShell Core - https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7#powershell-core
#### - Azure Stack Powershell AZ - https://docs.microsoft.com/en-us/azure-stack/operator/powershell-install-az-module?view=azs-2002

## Example
### CreateNewRole.ps1

## Aditional Information

### - How to create custom roles - https://docs.microsoft.com/en-us/azure/role-based-access-control/custom-roles
### - Azure Stack Admin API reference with documented operations - https://docs.microsoft.com/en-us/rest/api/azure-stack/