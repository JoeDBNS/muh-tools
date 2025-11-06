
$account_list_json = Get-Content -Path "./work/ad-account-timeout-list.json" -Raw | ConvertFrom-Json
$account_names = @()

foreach ($item in $account_list_json) {
    $account_names += $item.username
}

Import-Module ActiveDirectory

# Get all domain controllers in the domain
$domain_controllers = Get-ADDomainController -Filter *
$domain_controllers_count = $domain_controllers.Count

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
foreach ($domain_controller in $domain_controllers) {
    $progress_string = ""

    foreach ($i in 1..$current_domain_count) {
        $progress_string += [char]0x25A0
    }
    if ($domain_controllers_count - $current_domain_count -gt 0) {
       foreach ($i in 1..($domain_controllers_count - $current_domain_count)) {
            $progress_string += [char]0x25A1
        }
    }

    Write-Host "`n`n"
    Write-Host "$current_domain_count of $domain_controllers_count"
    Write-Host $progress_string
    Write-Host "Querying Domain Controller: $($domain_controller.HostName)" -ForegroundColor Cyan

    # Service Accounts don't have lastLogon but LastlogonTimestamp accuracy is going to rely on the AD Servers and Domain Controllers being in sync.
    $domain_controller_response = $account_names | Get-ADUser -Server $domain_controller.HostName -Properties lastLogon, LastlogonTimestamp | Select-Object SamAccountName, lastLogon, LastlogonTimestamp

    try {
        foreach ($response in $domain_controller_response) {
            $account_name = $response.SamAccountName.ToLower()

            if ($null -ne $response.lastLogon) {
                $account_last_logon = [DateTime]::FromFileTimeUtc($response.lastLogon)
                $account_latest_timestamp = $account_last_logon
            }
            else {
                if ($null -ne $response.LastlogonTimestamp) {
                    $account_last_logon_timestamp = [DateTime]::FromFileTimeUtc($response.LastlogonTimestamp)
                    $account_latest_timestamp = $account_last_logon_timestamp
                }
            }

            $timespan_compare = New-TimeSpan -Start $datetime_now -End $account_latest_timestamp
            $days_compare = $timespan_compare.Days

            if ($accounts[$account_name] -lt $days_compare) {
                $day_value_updates[$account_name] = $days_compare
                $account_last_logons[$account_name] = $account_latest_timestamp
                Write-Host ("Update:`t" + $account_latest_timestamp + "`t" + $account_name) -ForegroundColor "Blue"
            }
            else {
                Write-Host ("Done:`t" + $account_latest_timestamp + "`t" + $account_name) -ForegroundColor "Green"
            }

            foreach ($account_name in $day_value_updates.Keys) {
                $accounts[$account_name] = $day_value_updates[$account_name]
            }

            $day_value_updates = @{}

            $account_name = ""
            $account_last_logon = ""
            $account_last_logon_timestamp = ""
            $account_latest_timestamp = ""
        }
    }
    catch {
        Write-Host "ERROR within $($DomainController.HostName) query: $_" -ForegroundColor Red
    }

    $current_domain_count += 1
}


Write-Host "`n`n`n`n`n`n------------------------------------------------------------------------------------------`n`n`n$datetime_now`n"


foreach ($account_name in $accounts.Keys) {
    $text_color = "Green"

    if (($accounts[$account_name] + 90) -lt 30) {
        $text_color = "Red"
    }

    $account_last_logon_as_utc = [DateTime]::Parse($account_last_logons[$account_name])
    $timezone_eastern = [System.TimeZoneInfo]::FindSystemTimeZoneById("Eastern Standard Time")
    $account_last_logon_as_et = [System.TimeZoneInfo]::ConvertTimeFromUtc($account_last_logon_as_utc, $timezone_eastern)

    Write-Host ("" + $accounts[$account_name] + "`t" + $account_last_logon_as_et + "`t" + $account_name) -ForegroundColor $text_color
}

Write-Host "`n"