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
$Health = Get-AzsRegionHealth
$Capacity = $Health.UsageMetrics


#TimeStamp
$time = (get-date)

#Send Email Notification
$Subject = "Azure Stack Hub Capacity usage $time"
$Body =  $Capacity 

Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Credential $emailcredential -UseSsl



   