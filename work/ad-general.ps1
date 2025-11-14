# from bob: installs the necessary windows component for AD work
Get-WindowsCapability -Online | Where-Object { $_.Name -like "Rsat.ActiveDirectory.DS-LDS.Tools*" } | Add-WindowsCapability -Online


# Search for User by SOM name
Get-ADUser -Filter 'SamAccountName -like "*__username__*"' -Properties *
Get-ADUser -Filter 'SamAccountName -like "*__username__*"' -Properties memberof,Created
Get-ADUser -Filter 'SamAccountName -like "*__username__*"' -Properties memberof,Created | Select-Object Enabled,SamAccountName,Created,DistinguishedName
Get-ADUser -Filter 'SamAccountName -like "*__username__*"' -Properties Created | Select-Object Created | Select-String  -Pattern "2025"
Get-ADUser -Filter 'Enabled -eq "True"' -Properties memberof,Created | Select-Object Enabled,SamAccountName,Created,Name
Get-ADUser -Filter 'SamAccountName -like "wattsc5"' -Properties memberof,Created | Select-Object Enabled,SamAccountName,Created,Name

# Search for group by name
Get-ADGroup -Filter {Name -like 'ES_SADLC_*'}
Get-ADGroup -Filter {Name -like 'ES_SADLC_*'} | Select-Object Name

# Get Groups associated with User
Get-ADPrincipalGroupMembership __username__ | Select-Object Name | Sort-Object -property Name
# or
Get-ADUser __username__ -Properties memberof | Select-Object -Expand memberof

# Get Accounts that are part of a Group
Get-ADGroupMember -Identity __group__ | Select-Object SamAccountName



# Test credentials
$password = ConvertTo-SecureString "_____________" -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ("SOM\____________", $password)
Start-Process -FilePath "C:\Temp\do_nothing.exe" -Credential $credentials -WorkingDirectory 'C:\'

