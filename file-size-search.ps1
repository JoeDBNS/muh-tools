#powershell.exe -File "____________.ps1" --path "C:Windows"

$resolve_path = Resolve-Path ./

param (
    [string] $path = $resolve_path
)

$path = Resolve-Path ./
$result_count = 10

$files = Get-ChildItem -Path $path -Recurse -File |
    Select-Object @{Name = "FileName"; Expression = {$_.FullName}},
                  @{Name = "FileSizeMB"; Expression = {[math]::Round($_.Length / 1MB, 2)}},
                  @{Name = "ParentFolder"; Expression = {$_.Directory.Name}} |
    Sort-Object FileSizeMB -Descending

$files | Select-Object -First $result_count | Format-Table -AutoSize