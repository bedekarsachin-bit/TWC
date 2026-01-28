
$targetFile = "d:\Downloads Jan 26\new_TWC\new_TWC\blog\2025-04-semantic-search-optimization.html"

if (Test-Path $targetFile) {
    Write-Host "File exists."
    $content = Get-Content $targetFile -Raw
    
    # Test finding the pattern
    $pattern = 'href="services.html'
    if ($content.Contains($pattern)) {
        Write-Host "Found literal '$pattern'"
    }
    else {
        Write-Host "Did NOT find literal '$pattern'"
    }

    # Test Regex with negative lookbehind
    # (?<!\.\./)href="services\.html
    # Matches href="services.html" ONLY if not preceded by ../
    
    $regex = '(?<!\.\./)href="services\.html'
    $match = [regex]::Match($content, $regex)
    if ($match.Success) {
        Write-Host "Regex found match at index $($match.Index)"
        Write-Host "Context: $($content.Substring($match.Index, 20))..."
    }
    else {
        Write-Host "Regex did NOT match."
    }
}
else {
    Write-Host "File not found."
}
