rename-computer Naae
restart-computer
Stop-Computer
Get-NetIPConfiguration
new-netipaddress -InterfaceAlias ethernet -IPAddress 10.0.0.0 -PrefixLength 24 -DefaultGateway 192.0.0.1
set-dnsclientserveraddress -InterfaceAlias Ëthernet -ServerAddresses 192.0.0.1
Add-Computer -DomainName ff.loc

Get-NetAdapterStatistics
Test-NetConnection 
Test-Connection google.com -port 25
dfff
echo $?

Test-ComputerSecureChannel -Credential domain\admin -Repair #fix trust error
get-eventlog -LogName System -EntryType Error

Get-Service | Where-Object {$_.Status -eq "stopped"}

install-windowsfeatures
-IncludeAllsubfeature
-IncludeManagementTools File-Services

Install-WindowsFeature Net-Framework-Core -source d:\

Get-HotFix #check installed updates

New-NetFirewallRule -displayname "Allow Inbound Port 80" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow #block rplace allow with block

$pwd = ConvertTo-SecureString -String "Password01" -AsPlainText -Force
new-aduser -name test.user -accountpassword $pwd
enable-adaccount -identity test.user

set-adaccountpassword test.user -newpassword $pwd -reset -passthru | set-aduser -changepasswordatlogon $true 

new-adgroup -name "test" -samaccountname test -groupcategory security -groupscope global -path "CN=users,DC=IgniteNZ,DC=Internal"

search-adaccount -passwordneverexpire #-accountinactive -timespan 90.00:00:00 # -lockedout # -accountdisabled 

New-IseSnippet -Force -Title "Password_String" -Description "Secure Password String" -Text "`$newpwd = ConvertTo-SecureString -String P@ssw0rd -AsPlainText -Force"

add-dnsserverpri