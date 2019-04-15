=#Notification Configuration for Email
$secpasswd = ConvertTo-SecureString "EmailPassword" -AsPlainText -Force
$emailcredential = New-Object System.Management.Automation.PSCredential ("EmailAccountUsername", $secpasswd)
$From = "Sender Address"
$To = "Recipt Address"
$SMTPServer = "Mail Server"
$SMTPPort = "587"

#Environment Configuration
$armendpoint = "https://adminmanagement.local.azurestack.external"
$Thumbprint = ""
$ApplicationId = ""
$TenantId = ""

 
#Add Environment & Authenticate
Add-AzureRmEnvironment -Name "AzureStack" -ARMEndpoint $armendpoint
Add-AzureRmAccount -EnvironmentName "AzureStack" -ServicePrincipal -CertificateThumbprint $Thumbprint -ApplicationId $ApplicationId -TenantId $TenantId

#Retrieve Alerts -all active or by a specific severity 
$Alerts = get-azsalert |? {$_.State -eq "Active"} #-and $_.Severity -eq "Critical"}

#TimeStamp
$time = (get-date).AddMinutes(-5)

Foreach ($Alert in $Alerts) {

$difftime = new-timespan -start  $alert.CreatedTimestamp -End $time

If ($difftime -lt 10)

{
#Send Email Notification
$Subject = $Alert.Title
$Body =  $Alert.Description.text
Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Credential $emailcredential -UseSsl
}
else {}
}



   