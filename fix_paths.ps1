
$rootDir = "d:\Downloads Jan 26\new_TWC\new_TWC"
$dirsToCheck = @("pages", "blog")

# Regex replacements
# We use negative lookbehind (?<!\.\./) to ensure we don't match strings that already have ../
# We must escape dots in filenames.

$replacements = @(
    @{ Pattern = '(?<!\.\./)href="index\.html"'; Replacement = 'href="../index.html"' },
    @{ Pattern = '(?<!\.\./)href="about\.html"'; Replacement = 'href="../about.html"' },
    @{ Pattern = '(?<!\.\./)href="services\.html"'; Replacement = 'href="../services.html"' },
    @{ Pattern = '(?<!\.\./)href="services\.html#'; Replacement = 'href="../services.html#' },
    @{ Pattern = '(?<!\.\./)href="case-studies\.html"'; Replacement = 'href="../case-studies.html"' },
    @{ Pattern = '(?<!\.\./)href="contact\.html"'; Replacement = 'href="../contact.html"' },
    @{ Pattern = '(?<!\.\./)href="clients\.html"'; Replacement = 'href="../clients.html"' },
    @{ Pattern = '(?<!\.\./)href="industries\.html"'; Replacement = 'href="../industries.html"' },
    @{ Pattern = '(?<!\.\./)href="audit\.html"'; Replacement = 'href="../audit.html"' },
    @{ Pattern = '(?<!\.\./)href="privacy\.html"'; Replacement = 'href="../privacy.html"' },
    
    # Assets
    @{ Pattern = '(?<!\.\./)href="assets/'; Replacement = 'href="../assets/' },
    @{ Pattern = '(?<!\.\./)src="assets/'; Replacement = 'src="../assets/' },
    
    # Blog: Fix href="blog/..." to href="../blog/..." if seen from a subdirectory
    # Note: If we are in blog/, href="blog/post.html" implies blog/blog/post.html -> bad.
    # It should be just "post.html" or "../blog/post.html".
    # This rule is safe for pages/ and blog/ (makes it root-relative effectively).
    @{ Pattern = '(?<!\.\./)href="blog/'; Replacement = 'href="../blog/' }
)

foreach ($dirName in $dirsToCheck) {
    $dirPath = Join-Path $rootDir $dirName
    if (Test-Path $dirPath) {
        Write-Host "Processing directory: $dirPath"
        $files = Get-ChildItem -Path $dirPath -Filter *.html
        
        foreach ($file in $files) {
            $content = Get-Content $file.FullName -Raw
            $originalContent = $content
            
            foreach ($item in $replacements) {
                # PowerShell -replace operator uses Regex
                $content = $content -replace $item.Pattern, $item.Replacement
            }
            
            if ($content -ne $originalContent) {
                Write-Host "Fixed: $($file.Name)"
                $content | Set-Content $file.FullName -NoNewline
            }
            else {
                # Write-Host "No changes for $($file.Name)"
            }
        }
    }
}
Write-Host "Path fixing complete."
