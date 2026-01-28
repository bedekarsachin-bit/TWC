
# Script to mass-update blog post layouts to the new Premium Split-Hero design
$template = Get-Content "blog/post-template.html" -Raw

$files = Get-ChildItem -Path "blog" -Filter "*.html"

foreach ($file in $files) {
    if ($file.Name -eq "index.html" -or $file.Name -eq "post-template.html") { continue }

    $originalContent = Get-Content $file.FullName -Raw

    # 1. Extract Metadata using Regex
    $title = "Blog Post"
    if ($originalContent -match '<h1 class="hero-title.*?">(.*?)</h1>') { $title = $matches[1] }
    elseif ($originalContent -match '<h1 class="post-title.*?">(.*?)</h1>') { $title = $matches[1] }

    $category = "Insights"
    if ($originalContent -match 'class="blog-category".*?>(.*?)</span>') { $category = $matches[1] }
    elseif ($originalContent -match 'post-meta-header">(.*?) •') { $category = $matches[1].Trim() }

    $readTime = "5"
    if ($originalContent -match '(\d+) MIN READ') { $readTime = $matches[1] }

    $bodyContent = ""
    # Extract existing body content (careful not to duplicate hero)
    if ($originalContent -match '<div class="article-body">([\s\S]*?)</div>\s*</div>\s*</article>') { 
        $bodyContent = $matches[1].Trim() 
    }
    elseif ($originalContent -match '<div class="article-body">([\s\S]*?)</div>') {
        $bodyContent = $matches[1].Trim()
    }

    # 2. Determine Correct Image based on filename
    $img = "../assets/images/visuals/tech-seo-hero.png"
    if ($file.Name -match "seo|search|google") { $img = "../assets/images/visuals/seo-hero.png" }
    if ($file.Name -match "tech|core-web-vitals|semantic") { $img = "../assets/images/visuals/tech-seo-hero.png" }
    if ($file.Name -match "ads|ppc|facebook|meta|linkedin|bidding|programmatic|performance") { $img = "../assets/images/visuals/performance-hero.png" }
    if ($file.Name -match "analytics|ga4|data|tracking|mmm|retention") { $img = "../assets/images/visuals/analytics-hero.png" }
    if ($file.Name -match "hospitality") { $img = "../assets/images/visuals/industry-hospitality.png" }
    if ($file.Name -match "ecommerce") { $img = "../assets/images/visuals/industry-ecommerce.png" }
    if ($file.Name -match "education|edtech") { $img = "../assets/images/visuals/industry-education.png" }
    if ($file.Name -match "app|aso|mobile|voice") { $img = "../assets/images/visuals/mobile-app-hero.png" }
    if ($file.Name -match "design|cro|landing|content") { $img = "../assets/images/visuals/web-design-hero.png" }
    if ($file.Name -match "local|maps") { $img = "../assets/images/visuals/local-seo-hero.png" }

    # 3. Generate Table of Contents (Simplified)
    $toc = ""
    $bodyContent = [Regex]::Replace($bodyContent, '<h2 id="(.*?)">(.*?)</h2>', { 
            param($m) 
            $id = $m.Groups[1].Value
            $text = $m.Groups[2].Value
            $toc += "<li><a href='#$id'>$text</a></li>`n"
            return $m.Value
        })
    
    # 4. Inject into Template
    $newHtml = $template.Replace("{{TITLE}}", $title)
    $newHtml = $newHtml.Replace("{{CATEGORY}}", $category)
    $newHtml = $newHtml.Replace("{{READ_TIME}}", $readTime)
    $newHtml = $newHtml.Replace("{{AUTHOR}}", "The White Chalk Media Team")
    $newHtml = $newHtml.Replace("{{CONTENT}}", $bodyContent)
    $newHtml = $newHtml.Replace("{{TOC_ITEMS}}", $toc)
    
    # Replace the PLACEHOLDER image in template with specific one
    $newHtml = $newHtml.Replace("../assets/images/visuals/tech-seo-hero.png", $img)

    Set-Content -Path $file.FullName -Value $newHtml -Encoding UTF8
    Write-Host "Restored & Updated: $($file.Name)"
}
