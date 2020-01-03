# Copyright (c) Microsoft Corporation. All rights reserved.
# See LICENSE.txt in the project root for license information. 

<#
 
.SYNOPSIS 
 
Deploys Virtual Machine with all Tools for Azure Stack 

 
.DESCRIPTION 
 
It will create a virtual machine using a differencing disk.
It requires Hyper-V and a base virtual hard disk running Windows 10 or Windows Server 2019.
Internet access from the inside the virtual machine is required.
 
.PARAMETER VHDPath
Specify the path to the base VHD

.PARAMETER $vhdDiffPath
Specify the path to the differencing disk

.PARAMETER $DefaultGateway
Specify the default Gateway the virtual machine is using

.PARAMETER $IPAddress
Specify the IP Address the virtual machine is using

.PARAMETER $SubnetMask
Specify the Subnet Mask the virtual machine is using

.PARAMETER $DNSServer
Specify the DNS Server the virtual machine is using

.EXAMPLE
    $securePassword = Read-Host -Prompt "Enter password for Azure Stack Tools VM's local administrator" -AsSecureString
    . .\createtoolsvm.ps1
    deploy-vm -LocalAdministratorPassword $securePassword `
        -vhdpath "F:\SHARES\BUILDS\MAS_Prod\MAS_Prod_1.1912.0.29\en-US\Build\En\VHDLibrary\CloudBuilder.vhdx" `
        -vhddiffpath "F:\thoroet\ToolsVM\toolsvm.diff.vhdx" `
        -IPAddress "100.83.64.125" `
        -SubnetMask "255.255.255.192" `
        -DefaultGateway "100.83.64.65" `
        -DNSSERVER "10.10.240.23"
#>

#Requires -RunAsAdministrator

function deploy-vm {
Param(  
[string] $VhdPath,
[string] $vhdDiffPath,
[string] $DefaultGateway,
[string] $IPAddress,
[string] $SubnetMask,
[string] $DNSServer,
[Security.SecureString]
$LocalAdministratorPassword
)


#VM Parameters
$DeploymentVMName ="ToolsVM"
$VirtualSwitchName = "PublicSwitch"
$VirtualMachineMemory = 4GB
$VirtualProcessorCount = 4
$DynamicMemoryEnabled = $false
$VlanId ="0"


#Create Differencing Disk
New-VHD -Path $vhdDiffPath -ParentPath $VhdPath -Differencing

$unattendContent = @'
<unattend xmlns='urn:schemas-microsoft-com:unattend' xmlns:wcm='http://schemas.microsoft.com/WMIConfig/2002/State'>
    <settings pass='oobeSystem'>
        <component name='Microsoft-Windows-Shell-Setup' processorArchitecture='amd64' publicKeyToken='31bf3856ad364e35' language='neutral' versionScope='nonSxS'>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <SkipMachineOOBE>true</SkipMachineOOBE>
                <SkipUserOOBE>true</SkipUserOOBE>
                <NetworkLocation>Work</NetworkLocation>
            </OOBE>
            <AutoLogon>
                <Password>
                    <Value>[LocalAdministratorPassword]</Value>
                    <PlainText>true</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <LogonCount>1</LogonCount>
                <Username>Administrator</Username>
            </AutoLogon>
            <UserAccounts>
                <AdministratorPassword>
                    <Value>[LocalAdministratorPassword]</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
            </UserAccounts>
            <TimeZone>UTC</TimeZone>
        </component>
    </settings>
    <settings pass='specialize'>
        <component name='Microsoft-Windows-Shell-Setup' processorArchitecture='amd64' publicKeyToken='31bf3856ad364e35' language='neutral' versionScope='nonSxS'>
            <ComputerName>[DeploymentVMName]</ComputerName>
        </component>
        <component name='Networking-MPSSVC-Svc' processorArchitecture='amd64' publicKeyToken='31bf3856ad364e35' language='neutral' versionScope='nonSxS' xmlns:wcm='http://schemas.microsoft.com/WMIConfig/2002/State' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
            <DomainProfile_DisableNotifications>true</DomainProfile_DisableNotifications>
            <DomainProfile_EnableFirewall>false</DomainProfile_EnableFirewall>
            <PrivateProfile_DisableNotifications>true</PrivateProfile_DisableNotifications>
            <PrivateProfile_EnableFirewall>false</PrivateProfile_EnableFirewall>
            <PublicProfile_DisableNotifications>true</PublicProfile_DisableNotifications>
            <PublicProfile_EnableFirewall>false</PublicProfile_EnableFirewall>
            <FirewallGroups>
                <FirewallGroup wcm:action='add' wcm:keyValue='RemoteDesktop'>
                    <Active>true</Active>
                    <Profile>all</Profile>
                    <Group>@FirewallAPI.dll,-28752</Group>
                </FirewallGroup>
            </FirewallGroups>
        </component>
        <component name='Microsoft-Windows-TerminalServices-LocalSessionManager' processorArchitecture='amd64' publicKeyToken='31bf3856ad364e35' language='neutral' versionScope='nonSxS' xmlns:wcm='http://schemas.microsoft.com/WMIConfig/2002/State' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
            <fDenyTSConnections>false</fDenyTSConnections>
        </component>
        <component name="Microsoft-Windows-TCPIP" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <Interfaces>
                <Interface wcm:action="add">
                    <Ipv4Settings>
                        <DhcpEnabled>false</DhcpEnabled>
                    </Ipv4Settings>
                    <Identifier>Ethernet</Identifier>
                    <UnicastIpAddresses>
                        <IpAddress wcm:action="add" wcm:keyValue="1">[IPAddress]/[PrefixLength]</IpAddress>
                    </UnicastIpAddresses>
                    <Routes>
                        <Route wcm:action="add">
                            <Identifier>1</Identifier>
                            <NextHopAddress>[DefaultGateway]</NextHopAddress>
                            <Prefix>0.0.0.0/0</Prefix>
                        </Route>
                    </Routes>
                </Interface>
            </Interfaces>
        </component>
        <component name="Microsoft-Windows-DNS-Client" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
           <Interfaces>
               <Interface wcm:action="add">
                  <DNSServerSearchOrder>
                     <IpAddress wcm:action="add" wcm:keyValue="1">[DNSServer]</IpAddress>
                  </DNSServerSearchOrder>
                  <Identifier>Ethernet</Identifier>
               </Interface>
           </Interfaces>
        </component>
        <component name="Security-Malware-Windows-Defender" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DisableAntiSpyware>true</DisableAntiSpyware>
        </component>
    </settings>
</unattend>
'@


### Inject configuration parameters to customize the deployment VM
$mountPath = Join-Path -Path $env:TEMP -ChildPath ([GUID]::NewGuid())
New-Item $mountPath -ItemType Directory -Force | Out-Null

$unecryptedAdministratorPassword = (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'user',$LocalAdministratorPassword).GetNetworkCredential().Password
$PrefixLength = ([Convert]::ToString(([IPAddress] $SubnetMask).Address,2) -replace "0").Length
$unattendContent = $unattendContent.Replace('[DeploymentVMName]', $DeploymentVMName)
$unattendContent = $unattendContent.Replace('[LocalAdministratorPassword]', [System.Security.SecurityElement]::Escape($unecryptedAdministratorPassword))
$unattendContent = $unattendContent.Replace('[IPAddress]', $IPAddress)
$unattendContent = $unattendContent.Replace('[PrefixLength]', $PrefixLength)
$unattendContent = $unattendContent.Replace('[DefaultGateway]', $DefaultGateway)
$unattendContent = $unattendContent.Replace('[DNSServer]', $DNSServer)

Mount-WindowsImage -ImagePath $vhdDiffPath -Path $mountPath -Index 1 -Verbose:$false | Out-Null
$unattendTargetFolder = "$mountPath\Windows\Panther\Unattend"
New-Item $unattendTargetFolder -ItemType Directory -Force | Out-Null
Set-Content "$unattendTargetFolder\unattend.xml" -Value $unattendContent -Force
Dismount-WindowsImage -Path $mountPath -Save -Verbose:$false | Out-Null
Remove-Item $mountPath -Force

#Create Virtual Machine
$virtualMachine = New-VM -Name $DeploymentVMName -SwitchName $VirtualSwitchName -VHDPath $vhdDiffPath -MemoryStartupBytes $VirtualMachineMemory -Path (Split-Path $vhdDiffPath) -Generation 2
Disable-VMIntegrationService -VM $virtualMachine -Name 'Time Synchronization'
Set-VM -VM $virtualMachine -ProcessorCount $VirtualProcessorCount -AutomaticStartAction Start
Set-VMMemory -VM $virtualMachine -DynamicMemoryEnabled $DynamicMemoryEnabled
$virtualMachine | Get-VMNetworkAdapter | ? SwitchName -eq $VirtualSwitchName | Set-VMNetworkAdapterVlan -VlanId $VlanId -Access


#Install Tools

 ### Start the deployment VM and wait for it to repond to ping
        Write-Verbose "Starting VM '$DeploymentVMName'."
        Start-VM -VM $virtualMachine

        Write-Verbose "Awaiting response from VM '$DeploymentVMName'."
        $vmResponding = $false
        $retryCount = 0

        while (-not $vmResponding -and ($retryCount -lt 120)) 
        {
            Start-Sleep -Seconds 5
            $retryCount++
            $vmResponding = Test-Connection -ComputerName $IPAddress -Count 1 -Quiet
        }

        if ($vmResponding)

        {
            if ((Get-Service -Name WinRM).Status -ne [System.ServiceProcess.ServiceControllerStatus]::Running)
            {
                Write-Verbose -Message "Starting WinRM service"
                Start-Service -Name WinRM
            }

            Write-Verbose -Message "Trying to establish PowerShell session with $DeploymentVMName"
            $trustedHosts = (Get-Item -Path "WSMan:\localhost\Client\TrustedHosts").Value
            if ($trustedHosts)
            {
                if ($trustedHosts -notcontains "*")
                {
                    Set-Item -Path "WSMan:\localhost\Client\TrustedHosts" -Value "$trustedHosts,$IPAddress" -Force
                }
            }
            else
            {
                Set-Item -Path "WSMan:\localhost\Client\TrustedHosts" -Value $IPAddress -Force    
            }

            $psSession = $null
            $retryCount = 0
            $dvmCredential = New-Object -Type System.Management.Automation.PSCredential -ArgumentList "Administrator", $LocalAdministratorPassword
            while (-not $psSession -and ($retryCount -lt 10))
            {
                Start-Sleep -Seconds 30
                try
                {
                    $psSession = New-PSSession -ComputerName $IPAddress -Credential $dvmCredential
                }
                catch 
                {
                    $retryCount++
                    Write-Verbose "... attempt $retryCount"
                }
            }
            if ($psSession)
            {
                Write-Output "Running Tools Installation"

                 Invoke-Command -Session $psSession -ScriptBlock {

                        

                        #Test Internet Connecvtivity
                        $Validator1=Test-NetConnection -ComputerName github.com  -Port 443
                        $Validator2=Test-NetConnection -ComputerName the.earth.li  -Port 443
                        $Validator3=Test-NetConnection -ComputerName powershellgallery.com  -Port 443
                        
                        
                        If($Validator1.TcpTestSucceeded -ne $true -and $Validator2.TcpTestSucceeded -ne $true -and $Validator3.TcpTestSucceeded -ne $true)
                        {
                        write-output "There is no internet access. Tools installation was skipped please use the guidanceto install tools for disconnected environments"
                        }
                        else
                        {
                        #Trust PS Gallery
                        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
                        
                        #Uninstall any previous versions
                        Get-Module -Name Azs.* -ListAvailable | Uninstall-Module -Force -Verbose
                        Get-Module -Name Azure* -ListAvailable | Uninstall-Module -Force -Verbose
                        
                        # Install the AzureRM.BootStrapper module. Select Yes when prompted to install NuGet
                        Install-Module -Name AzureRM.BootStrapper -force -AllowClobber

                        # Install and import the API Version Profile required by Azure Stack into the current PowerShell session.
                        Use-AzureRmProfile -Profile 2019-03-01-hybrid -Force -WarningAction silentlycontinue
                        Install-Module -Name AzureStack -RequiredVersion 1.8.1 -force -AllowClobber -WarningAction SilentlyContinue

                        #Download Tools from Github
                        invoke-webrequest -Uri "https://github.com/Azure/AzureStack-Tools/archive/master.zip" -outfile c:\tools\master.zip
                        Expand-Archive -Path c:\tools\master.zip -DestinationPath c:\ -force

                        #Download Putty & Install Putty
                        invoke-webrequest -Uri "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.73-installer.msi" -OutFile c:\tools\putty-64bit-0.73-installer.msi
                        c:\tools\putty-64bit-0.73-installer.msi -quiet -norestart

                        #Download & Install Azure Storage Tools
                        invoke-webrequest -Uri "https://aka.ms/downloadazcopy-v10-windows" -outfile c:\tools\azcopy.zip
                        Expand-Archive -Path c:\tools\azcopy.zip -DestinationPath c:\tools -force
                        $env:AZCOPY_DEFAULT_SERVICE_API_VERSION="2017-11-09"

                        #Download & Install Azure Storage Explorer
                        invoke-webrequest -Uri "https://go.microsoft.com/fwlink/?LinkId=708343&clcid=0x409" -OutFile c:\tools\StorageExplorer.exe
                        c:\tools\storageexplorer.exe /silent /SP-

                        #Download $ Install Azure CLI
                        Invoke-WebRequest -Uri "https://aka.ms/installazurecliwindows" -OutFile c:\tools\AzureCLI.msi
                        c:\tools\AzureCLI.msi /quiet

                        }
                        

                    }
                }
                else
            {
                Write-Output "$DeploymentVMName failed to respond"
            }
        }
        elseif ($vmResponding) 
        {
            Write-Output "$DeploymentVMName is ready"
        }
        else 
        {
            Write-Output "$DeploymentVMName failed to respond"
        }
    }
    