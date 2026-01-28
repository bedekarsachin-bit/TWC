$ProjectRoot = "c:\Users\SACHIN\Downloads\new_TWC\new_TWC"
$IndexFile = Join-Path $ProjectRoot "index.html"
$BlogDir = Join-Path $ProjectRoot "blog"

Write-Host "Reading master header from index.html..."
$IndexContent = Get-Content -Path $IndexFile -Raw

# Extract header content
if ($IndexContent -match '(?s)(<header class="site-header">.*?</header>)') {
    $MasterHeader = $matches[1]
}
else {
    Write-Error "Could not find <header class='site-header'> in index.html"
    exit
}

Write-Host "Adapting header for blog subdirectory..."
# Adapt paths
$BlogHeader = $MasterHeader -replace 'href="assets/', 'href="../assets/'
$BlogHeader = $BlogHeader -replace 'src="assets/', 'src="../assets/'
$BlogHeader = $BlogHeader -replace 'href="pages/', 'href="../pages/'

# Root links
$BlogHeader = $BlogHeader -replace 'href="index.html"', 'href="../index.html"'
$BlogHeader = $BlogHeader -replace 'href="services.html"', 'href="../services.html"'
$BlogHeader = $BlogHeader -replace 'href="case-studies.html"', 'href="../case-studies.html"'
$BlogHeader = $BlogHeader -replace 'href="clients.html"', 'href="../clients.html"'
$BlogHeader = $BlogHeader -replace 'href="about.html"', 'href="../about.html"'
$BlogHeader = $BlogHeader -replace 'href="contact.html"', 'href="../contact.html"'
$BlogHeader = $BlogHeader -replace 'href="audit.html"', 'href="../audit.html"'
$BlogHeader = $BlogHeader -replace 'href="privacy.html"', 'href="../privacy.html"'

# Anchor links
$BlogHeader = $BlogHeader -replace 'href="#services"', 'href="../index.html#services"'

# Self-referential links (fixing "blog/" references)
# If master has href="blog/index.html", it becomes href="index.html" inside blog/
$BlogHeader = $BlogHeader -replace 'href="blog/', 'href="'
# Also handle if it was href="blog/"
$BlogHeader = $BlogHeader -replace 'href="blog/"', 'href="./"'

Write-Host "Scanning $BlogDir..."
$Files = Get-ChildItem -Path $BlogDir -Filter "*.html" -Recurse

$Count = 0
foreach ($File in $Files) {
    $Content = Get-Content -Path $File.FullName -Raw
    
    # Check if file has a header to replace
    # We look for <header class="site-header">... or <header class="main-header">... or just <header>...
    # Using a broad regex to capture the first header block
    if ($Content -match '(?s)(<header.*?>.*?</header>)') {
        $OldHeader = $matches[1]
        
        # Only update if different (ignoring whitespace differences could be good, but strict string compare is safer for now)
        # Note: $BlogHeader might have slightly different formatting than $OldHeader, so we just replace.
        
        $NewContent = $Content -replace '(?s)(<header.*?>.*?</header>)', $BlogHeader
        
        # We need to ensure we only replaced the FIRST occurrence.
        # -replace in PowerShell replaces ALL occurrences by default.
        # But usually there is only one header. To be safe, let's assume one.
        
        if ($NewContent -ne $Content) {
            Set-Content -Path $File.FullName -Value $NewContent -Encoding UTF8
            Write-Host "Updated: $($File.Name)"
            $Count++
        }
        else {
            Write-Host "Skipped (identical): $($File.Name)"
        }
    }
    else {
        Write-Host "Skipped (no header found): $($File.Name)"
    }
}

Write-Host "Done. Updated $Count files."
