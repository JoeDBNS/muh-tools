#powershell.exe -File "____________.ps1" --url "https://imgs.xkcd.com/comics/tech_support_cheat_sheet.png" --name "xkcd-it-support-comic"

param (
    [string] $url = "https://imgs.xkcd.com/comics/tech_support_cheat_sheet.png",
    [Parameter(ParameterSetName="name")]
    [string] $overwrite_name = ""
)

$file_name_full = ($url -split "/")[-1]
# $file_name, $file_extention = ($file_name_full -split "\.")[0, -1]

if ($overwrite_name -eq "") {
    $overwrite_name = ($file_name_full -split "\.")[0]
}

try {
    $wc = New-Object System.Net.WebClient

    $wc.DownloadFile($url, "C:\temp\$file_name_full")
} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}


Write-Host `n$_ -ForegroundColor Cyan