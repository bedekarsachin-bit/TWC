
$rootPath = "c:\Users\SACHIN\Downloads\new_TWC\new_TWC"
$reportFile = "image_audit_report.txt"
$brokenCount = 0

Write-Host "Starting Image Audit..."
$reportContent = "Image Audit Report - $(Get-Date)`n-----------------------------------`n"

# Get all HTML files
$htmlFiles = Get-ChildItem -Path $rootPath -Filter *.html -Recurse

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw
    
    # Regex to find img src tags
    $matches = [regex]::Matches($content, '<img[^>]+src=["'']([^"'']+)["'']', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    foreach ($match in $matches) {
        $src = $match.Groups[1].Value
        
        if ([string]::IsNullOrWhiteSpace($src)) { continue }

        # Skip external links, data URIs, and server-side templates
        if ($src -match "^http" -or $src -match "^data:" -or $src -match "^#" -or $src -match "^{{") {
            continue
        }

        try {
            # Resolve path
            $decodedSrc = [System.Uri]::UnescapeDataString($src)
            
            # Handle root-relative paths (starting with /)
            if ($decodedSrc.StartsWith("/")) {
                $fullPath = Join-Path $rootPath $decodedSrc.TrimStart("/")
            }
            else {
                # Handle relative paths
                $fullPath = [System.IO.Path]::GetFullPath((Join-Path $file.DirectoryName $decodedSrc))
            }

            if (-not (Test-Path $fullPath)) {
                $brokenCount++
                $relPath = $file.FullName.Replace($rootPath, "")
                $msg = "BROKEN: '$src' in file '$relPath'"
                Write-Host $msg -ForegroundColor Red
                $reportContent += "$msg`n"
                # Suggestion logic
                $fileName = [System.IO.Path]::GetFileName($decodedSrc)
                $found = Get-ChildItem -Path $rootPath -Filter $fileName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($found) {
                    $reportContent += "  -> SUGGESTION: Found similar file at: $($found.FullName.Replace($rootPath, ''))`n"
                }
                else {
                    $reportContent += "  -> NO SUGGESTION FOUND`n"
                }
            }
        }
        catch {
            Write-Host "Error processing '$src' in $($file.Name): $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

$reportContent += "`nTotal Broken Images: $brokenCount"
Set-Content -Path (Join-Path $rootPath $reportFile) -Value $reportContent
Write-Host "Audit Complete. Found $brokenCount broken images. Report saved to $reportFile"
