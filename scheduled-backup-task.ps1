
# ----- NOTES -----

# Open PowerShell as Admin
# powershell.exe -noexit -ExecutionPolicy Bypass -File '___path to file____\scheduled-backup-task.ps1'


# ----- INPUTS & VARIABLES -----

[string] $source_path = Read-Host "Enter Full Path Of Folder to Backup"
[string] $source_name = $source_path.Split("\") | Select-Object -Last 1

[string] $backups_path = "$env:USERPROFILE\Backups"
[string] $target_path = "$backups_path\$source_name\$UnixTimeStamp"

[string] $task_scripts_path = "$env:USERPROFILE\ScheduledTaskScripts\"
[string] $task_scripts_file_name = "FolderBackupScript-$source_name.ps1"


# ----- Backup Code -----

$BackupCodeAsText = @"
    [int] `$UnixTimeStamp = (Get-Date -UFormat %s -Millisecond 0)
    [string] `$target_path = "$backups_path\$source_name\`$UnixTimeStamp"

    New-Item -Path "`$target_path" -ItemType Directory
    Copy-item -Force -Recurse "$source_path" -Destination "`$target_path"
"@


# ----- Create Backup Script File -----

New-Item -Force -ItemType File `
    -Path $task_scripts_path `
    -Name $task_scripts_file_name `
    -Value $BackupCodeAsText


# ----- Create Task -----

# Requires execute as Admin to set principal below
$Actions = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$task_scripts_path$task_scripts_file_name`""
$Trigger = New-ScheduledTaskTrigger -Daily -At "12:00 PM"
$Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -WakeToRun -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$Task = New-ScheduledTask -Action $Actions -Trigger $Trigger -Principal $Principal -Settings $Settings

Register-ScheduledTask "Personal\FolderBackupScript-$SourceName" -InputObject $Task