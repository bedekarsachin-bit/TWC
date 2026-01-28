$path = "c:/Users/SACHIN/Downloads/new_TWC/new_TWC/about.html"
$content = Get-Content -Path $path -Raw -Encoding UTF8

$frameworksIcon = @"
<div class="icon">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
        stroke-linecap="round" stroke-linejoin="round">
        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
    </svg>
</div>
"@

$careersIcon = @"
<div class="icon">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
        stroke-linecap="round" stroke-linejoin="round">
        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
        <circle cx="9" cy="7" r="4" />
        <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
        <path d="M16 3.13a4 4 0 0 1 0 7.75" />
    </svg>
</div>
"@

# Use regex to match the anchor tag followed by the icon div
$content = $content -replace '(<a href="pages/frameworks.html" class="mega-item">)\s*<div class="icon">.*?</div>', "`$1`n                                        $frameworksIcon"
$content = $content -replace '(<a href="contact.html" class="mega-item">)\s*<div class="icon">.*?</div>', "`$1`n                                        $careersIcon"

Set-Content -Path $path -Value $content -Encoding UTF8
Write-Host "Successfully updated about.html icons using regex"
