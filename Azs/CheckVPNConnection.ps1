#Notification Configuration for Email
$secpasswd = ConvertTo-SecureString "EmailPassword" -AsPlainText -Force
$emailcredential = New-Object System.Management.Automation.PSCredential ("EmailAccountUsername", $secpasswd)
$From = "Sender Address"
$To = "Recipt Address"
$SMTPServer = "Mail Server"
$SMTPPort = "587"

#Environment Configuration
$armendpoint = "https://management.local.azurestack.external"
$Thumbprint = ""
$ApplicationId = ""
$TenantId = ""
$RG = ""
 
#Add Environment & Authenticate
Add-AzureRmEnvironment -Name "AzureStack" -ARMEndpoint $armendpoint
Add-AzureRmAccount -EnvironmentName "AzureStack" -ServicePrincipal -CertificateThumbprint $Thumbprint -ApplicationId $ApplicationId -TenantId $TenantId



#VPN Connections
$Connections = get-azurermvirtualnetworkgatewayconnection  -ResourceGroupName $RG 

#Check Connection State and Alert if not connected
Foreach ($connection in $Connections) {
If ($connection.connectionstatus -eq "NotConnected")
{
#Send Email Notification
$Subject = $Connection.Name
$Body =  $Connection.Name is $Connection.ConnectionStatus
Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Credential $emailcredential -UseSsl
#Add potential remediaiton steps
}
else {}
}
