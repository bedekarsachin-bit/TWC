
# audit_report_gen.ps1
# Script to generate a detailed audit report for all HTML pages

$rootPath = "d:\Downloads Jan 26\new_TWC\new_TWC"
$outputFile = "$rootPath\full_site_audit.csv"

# Function to clean path
function Clean-Path($path) {
    if ($path -match '[\?#]') {
        $path = $path -split '[\?#]' | Select-Object -First 1
    }
    return $path
}

# Get all HTML files
$files = Get-ChildItem -Path $rootPath -Recurse -Filter *.html

$results = @()

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # 1. Word Count (Approximate: Body Strip Tags)
    # Using regex to remove scripts, styles, and html tags
    $bodyContent = $content -replace '<script[\s\S]*?</script>', '' `
        -replace '<style[\s\S]*?</style>', '' `
        -replace '<[^>]+>', ' ' 
    $wordCount = ($bodyContent -split '\s+' | Where-Object { $_ -ne '' }).Count

    # 2. Check for "Lorem Ipsum"
    $hasLorem = $content -match "lorem ipsum"

    # 3. Check for Header / Footer / Main
    $hasHeader = $content -match "<header"
    $hasFooter = $content -match "<footer"
    $hasMain = $content -match "<main"
    
    # 4. Broken Images
    $imgMatches = [regex]::Matches($content, '<img[^>]+src=["'']([^"'']+)["'']')
    $brokenImages = @()
    foreach ($match in $imgMatches) {
        $src = $match.Groups[1].Value
        # Filter external and data URLs
        if ($src -notmatch "^http" -and $src -notmatch "^data:" -and $src -notmatch "^//" ) {
            # Resolve path
            $srcClean = Clean-Path $src
            $resolvedPath = $null
             
            if ($srcClean.StartsWith("/")) {
                # Absolute from root (unlikely in this static setup but possible)
                $resolvedPath = Join-Path $rootPath ($srcClean.TrimStart("/"))
            }
            else {
                # Relative
                $resolvedPath = Join-Path $file.DirectoryName $srcClean
            }
             
            if (-not (Test-Path $resolvedPath)) {
                $brokenImages += $src
            }
        }
    }
    $brokenImagesCount = $brokenImages.Count

    # 5. UI Consistency: Inline Styles (Count)
    $inlineStylesCount = ([regex]::Matches($content, 'style=["''][^"'']*["'']')).Count

    $results += [PSCustomObject]@{
        Files             = $file.FullName.Replace($rootPath, "")
        WordCount         = $wordCount
        HasLorem          = $hasLorem
        HasHeader         = $hasHeader
        HasFooter         = $hasFooter
        HasMain           = $hasMain
        BrokenImagesCount = $brokenImagesCount
        BrokenImagesList  = ($brokenImages -join "; ")
        InlineStylesCount = $inlineStylesCount
    }
}

$results | Export-Csv -Path $outputFile -NoTypeInformation
Write-Host "Audit Complete. Saved to $outputFile"
