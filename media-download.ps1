#powershell.exe -File "____________.ps1" --url "https://imgs.xkcd.com/comics/tech_support_cheat_sheet.png" --name "xkcd-it-support-comic"

param (
    [string] $url = "https://imgs.xkcd.com/comics/tech_support_cheat_sheet.png",
    [Parameter(ParameterSetName="name")]
    [string] $overwriteName = ""
)

$fileNameFull = ($url -split "/")[-1]
# $fileName, $fileExtention = ($fileNameFull -split "\.")[0, -1]

if ($overwriteName -eq "") {
    $overwriteName = ($fileNameFull -split "\.")[0]
}

try {
    $wc = New-Object System.Net.WebClient

    $wc.DownloadFile($url, "C:\temp\$fileNameFull")
} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}


Write-Host `n$_ -ForegroundColor Cyan