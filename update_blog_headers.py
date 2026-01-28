import os
import re

# Configuration
PROJECT_ROOT = r"c:\Users\SACHIN\Downloads\new_TWC\new_TWC"
INDEX_FILE = os.path.join(PROJECT_ROOT, "index.html")
BLOG_DIR = os.path.join(PROJECT_ROOT, "blog")

def get_master_header():
    with open(INDEX_FILE, 'r', encoding='utf-8') as f:
        content = f.read()
        # Extract content between <header class="site-header"> and </header>
        match = re.search(r'(<header class="site-header">.*?</header>)', content, re.DOTALL)
        if match:
            return match.group(1)
        return None

def adapt_header_for_blog(header_content):
    # Replace links to be relative from blog/ directory
    # 1. Assets
    header_content = header_content.replace('href="assets/', 'href="../assets/')
    header_content = header_content.replace('src="assets/', 'src="../assets/')
    
    # 2. Pages
    header_content = header_content.replace('href="pages/', 'href="../pages/')
    
    # 3. Root files
    header_content = header_content.replace('href="index.html"', 'href="../index.html"')
    header_content = header_content.replace('href="services.html"', 'href="../services.html"')
    header_content = header_content.replace('href="case-studies.html"', 'href="../case-studies.html"')
    header_content = header_content.replace('href="clients.html"', 'href="../clients.html"')
    header_content = header_content.replace('href="about.html"', 'href="../about.html"')
    header_content = header_content.replace('href="contact.html"', 'href="../contact.html"')
    header_content = header_content.replace('href="audit.html"', 'href="../audit.html"')
    header_content = header_content.replace('href="privacy.html"', 'href="../privacy.html"')
    
    # 4. Dictionary link (if any) and Anchor links
    # Fix specific anchor links to go to root index
    header_content = header_content.replace('href="#services"', 'href="../index.html#services"')
    
    # 5. Fix self-referential blog links
    # If the master header has href="blog/index.html", it should become href="index.html" when inside blog dir
    # But wait, typically index.html in root links to "blog/index.html" or "blog/".
    # Let's check how it is in master: href="pages/blog/index.html" or "blog/index.html"?
    # In the viewed index.html, it wasn't explicitly visible in the first 150 lines but likely is there.
    # We will safely assume we might need to adjust "blog/" references.
    
    # Actually, looking at index.html (line 398 in previous turn logs): <li><a href="../blog/index.html">Blog</a></li>
    # Wait, in the ROOT index.html, it would just be "blog/index.html".
    # Let's just do a generic replace for "blog/"
    header_content = header_content.replace('href="blog/', 'href="') 
    
    # Correction: If original is href="blog/index.html", and we are IN blog/, it should be href="index.html"
    # The replace above 'href="blog/' -> 'href="' turns 'href="blog/index.html"' into 'href="index.html"'. Correct.
    
    return header_content

def update_file(file_path, new_header):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Regex to find existing header
    # It might be <header class="site-header"> or just <header> or <header class="main-header">
    # The blog files seemed to use <header class="site-header"> based on viewed file.
    # But let's be robust and look for <header.*?>...</header>
    
    # IMPORTANT: We only want to replace the first header if there are multiple (unlikely but possible)
    updated_content = re.sub(r'<header.*?>.*?</header>', new_header, content, count=1, flags=re.DOTALL)
    
    if content != updated_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(updated_content)
        return True
    return False

def main():
    print("Reading master header from index.html...")
    master_header = get_master_header()
    if not master_header:
        print("Error: Could not find <header class='site-header'> in index.html")
        return

    print("Adapting header for blog subdirectory...")
    blog_header = adapt_header_for_blog(master_header)
    
    print(f"Scanning {BLOG_DIR}...")
    count = 0
    for root, dirs, files in os.walk(BLOG_DIR):
        for file in files:
            if file.endswith(".html"):
                file_path = os.path.join(root, file)
                if update_file(file_path, blog_header):
                    print(f"Updated: {file}")
                    count += 1
                else:
                    print(f"Skipped (no change): {file}")
    
    print(f"Done. Updated {count} files.")

if __name__ == "__main__":
    main()
