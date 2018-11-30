$FQDN = "azurestack.external"
$RegionName = "local"

#Set Parameter
$secpasswd = ConvertTo-SecureString "EmailAccountPassword" -AsPlainText -Force
$emailcredential = New-Object System.Management.Automation.PSCredential ("EmailAccountUserName", $secpasswd)
$From = "SenderEmailAddress"
$To = "ReceiptEmailAddress"
$Subject = "Azure Stack ERCS Alert"
$SMTPServer = "MailServer"
$SMTPPort = "587"

#Add & Authenticate environment
Add-AzureRmEnvironment -Name Admin -ARMEndpoint https://adminmanagement.$regionname.$FQDN |out-null
Add-AzureRmAccount -Environment Admin|Out-Null

$Alerts=Get-AzsAlert | where {($_.State -eq "Active" -and $_.Title -eq "Infrastructure role instance unavailable")}|select ImpactedResourceDisplayName


Foreach ($alert in $alerts){

If ($alert |where {$_.ImpactedResourceDisplayName -like "*ERCS*"})

{
Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Credential $emailcredential -UseSsl
}
}







