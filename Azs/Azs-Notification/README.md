# AzsAlertNotification

## Sample script that does retrieve Azure Stack Health Alerts and sends email notification

## Usage Scenario

### The script should run as a scheduled task every 5 minutes on a machine that can reach the Azure Stack Admin ARM endpoint. Once an Alert is found that is less than 10 minutes old an email notificatio is send. 


## Requirements

### - A machine running Windows with PowerShell 5.0
### - A Service Principal using a certificate ( See details here: https://docs.microsoft.com/en-us/azure/azure-stack/user/azure-stack-create-service-principals)
### - Azure Stack PowerShell must be installed (See details here: https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-powershell-install)

## Setup

### - Configure Email Account details
### - Configure ARM Endpoint
### - Configure SPN details