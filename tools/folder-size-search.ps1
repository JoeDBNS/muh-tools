# Get all directories in the current path
$folders = Get-ChildItem -Directory

# Create a list of objects with folder name and size
$folderSizes = foreach ($folder in $folders) {
    $size = (Get-ChildItem -Path $folder.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    [PSCustomObject]@{
        Name = $folder.Name
        SizeMB = [math]::Round($size / 1MB, 2)
    }
}

# Sort the folders by size in descending order and display the result
$folderSizes | Sort-Object SizeMB -Descending | Format-Table -AutoSize