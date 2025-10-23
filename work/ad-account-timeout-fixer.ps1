
$password = ConvertTo-SecureString "_________________" -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ("SOM\_________________", $password)
Start-Process -FilePath "C:\Temp\do_nothing.exe" -Credential $credentials -WorkingDirectory 'C:\'
