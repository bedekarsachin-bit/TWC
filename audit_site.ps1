
$rootPath = "d:\Downloads Jan 26\new_TWC\new_TWC"
$htmlFiles = Get-ChildItem -Path $rootPath -Filter *.html -Recurse

$results = @()

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw
    
    # 1. Broken Internal Links Check
    $links = [regex]::Matches($content, 'href="([^"#][^"]*)"') 
    foreach ($link in $links) {
        $target = $link.Groups[1].Value
        
        # Skip external links and empty/hash links
        if ($target -match "^http" -or $target -match "^mailto" -or $target -match "^tel") { continue }
        
        # Strip anchor (#) and query (?)
        if ($target -match "([^#?]+)") {
            $pathOnly = $matches[1]
        }
        else {
            $pathOnly = $target
        }

        # Calculate absolute path for local file
        $targetPath = ""
        if ($pathOnly -match "^/") {
            # Root relative (assuming root is $rootPath)
            $targetPath = Join-Path $rootPath $pathOnly.TrimStart('/')
        }
        else {
            # Relative to current file
            $targetPath = Join-Path $file.DirectoryName $pathOnly
        }
        
        # Check if file exists
        if (-not (Test-Path $targetPath)) {
            $results += [PSCustomObject]@{
                Filesource = $file.Name
                Type       = "Broken Link"
                Target     = $target
                Details    = "Target file not found at: $targetPath"
            }
        }
    }

    # 2. Missing Alt Tags Check
    $images = [regex]::Matches($content, '<img\s+[^>]*>')
    foreach ($img in $images) {
        $imgTag = $img.Value
        if ($imgTag -notmatch 'alt="([^"]*)"' -or $imgTag -match 'alt=""') {
            $results += [PSCustomObject]@{
                Filesource = $file.Name
                Type       = "Missing Alt"
                Target     = "Image Tag"
                Details    = $imgTag
            }
        }
    }
}

$results | Export-Csv -Path "d:\Downloads Jan 26\new_TWC\new_TWC\audit_results.csv" -NoTypeInformation
