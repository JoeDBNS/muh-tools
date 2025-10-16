
Import-Module ActiveDirectory

# Get all domain controllers in the domain
$domain_controllers = Get-ADDomainController -Filter *
$domain_controllers_count = $domain_controllers.Count

$account_names = @(
    "davisj38"
)

$default_last_login_span = -999999
$accounts = @{}
$account_last_logons = @{}

foreach ($account_name in $account_names) {
    $accounts[$account_name] = $default_last_login_span
}

foreach ($account_name in $account_names) {
    $account_last_logons[$account_name] = Get-Date '1900-01-01'
}

$day_value_updates = @{}

$datetime_now = Get-Date

$current_domain_count = 1
foreach ($DomainController in $domain_controllers) {
    $progress_string = ""

    foreach ($i in 1..$current_domain_count) {
        $progress_string += [char]0x25A0
    }
    if ($domain_controllers_count - $current_domain_count -gt 0) {
       foreach ($i in 1..($domain_controllers_count - $current_domain_count)) {
            $progress_string += [char]0x25A1
        }
    }

    Write-Host "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n"
    Write-Host "$current_domain_count of $domain_controllers_count"
    Write-Host $progress_string
    Write-Host "Querying Domain Controller: $($DomainController.HostName)" -ForegroundColor Cyan

    try {
        foreach ($account_name in $account_names) {
            try {
                $timestamp_account_last_logon = Get-ADUser -Server $DomainController.HostName -Identity $account_name -Properties lastLogon | Select-Object -ExpandProperty lastLogon
                $datetime_account_last_logon = [DateTime]::FromFileTimeUtc($timestamp_account_last_logon)

                $timespan_compare = New-TimeSpan -Start $datetime_now -End $datetime_account_last_logon
                $days_compare = $timespan_compare.Days

                if ($accounts[$account_name] -lt $days_compare) {
                    $day_value_updates[$account_name] = $days_compare
                    $account_last_logons[$account_name] = $datetime_account_last_logon
                    Write-Host ("Update:`t" + $account_name) -ForegroundColor "Blue"
                }
                else {
                    Write-Host ("Done:`t" + $account_name) -ForegroundColor "Green"
                }
            }
            catch {
                # Service Accounts don't have lastLogon but LastlogonTimestamp accuracy is going to rely on the AD Servers and Domain Controllers being in sync.
                try {
                    $timestamp_account_last_logon = Get-ADUser -Server $DomainController.HostName -Identity $account_name -Properties LastlogonTimestamp | Select-Object -ExpandProperty LastlogonTimestamp
                    $datetime_account_last_logon = [DateTime]::FromFileTimeUtc($timestamp_account_last_logon)

                    $timespan_compare = New-TimeSpan -Start $datetime_now -End $datetime_account_last_logon
                    $days_compare = $timespan_compare.Days

                    if ($accounts[$account_name] -lt $days_compare) {
                        $day_value_updates[$account_name] = $days_compare
                        $account_last_logons[$account_name] = $datetime_account_last_logon
                        Write-Host ("Update:`t" + $account_name) -ForegroundColor "Blue"
                    }
                    else {
                        Write-Host ("Done:`t" + $account_name) -ForegroundColor "Green"
                    }
                }
                catch {
                    Write-Host ("00`tERROR`t`t`t" + $account_name) -ForegroundColor "Red"
                }
            }
        }

        foreach ($account_name in $day_value_updates.Keys) {
            $accounts[$account_name] = $day_value_updates[$account_name]
        }

        $day_value_updates = @{}
    }
    catch {
        Write-Host "ERROR within $($DomainController.HostName) query: $_" -ForegroundColor Red
    }

    $current_domain_count += 1
}


Write-Host "`n`n`n`n`n`n------------------------------------------------------------------------------------------`n`n`n"


foreach ($account_name in $accounts.Keys) {
    $text_color = "Green"

    if (($accounts[$account_name] + 90) -lt 30) {
        $text_color = "Red"
    }

    Write-Host ("" + $accounts[$account_name] + "`t" + $account_last_logons[$account_name] + "`t" + $account_name) -ForegroundColor $text_color
}

Write-Host "`n`n"