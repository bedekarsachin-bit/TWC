
import os
import re

root_dir = r"d:\Downloads Jan 26\new_TWC\new_TWC"
dirs_to_fix = [os.path.join(root_dir, "pages"), os.path.join(root_dir, "blog")]

# Map of common root-level targets to their relative path from a Level 1 subdirectory
# e.g. Inside pages/, "index.html" should replace "index.html" with "../index.html" 
# BUT we must be careful not to replace "pages/index.html" (if that existed) incorrectly.
# So we look for specific href patterns.

replacements = [
    # Navigation Links
    (r'href="index.html"', r'href="../index.html"'),
    (r'href="about.html"', r'href="../about.html"'),
    (r'href="services.html"', r'href="../services.html"'),
    (r'href="services.html#', r'href="../services.html#'),
    (r'href="case-studies.html"', r'href="../case-studies.html"'),
    (r'href="contact.html"', r'href="../contact.html"'),
    (r'href="clients.html"', r'href="../clients.html"'),
    (r'href="industries.html"', r'href="../industries.html"'),
    (r'href="audit.html"', r'href="../audit.html"'),
    (r'href="privacy.html"', r'href="../privacy.html"'),
    
    # Blog Link (careful, as blog/index.html is inside blog/ folder, so fro blog/post.html it is just "index.html")
    # Actually, existing links in root are "blog/index.html".
    # From pages/, it should be "../blog/index.html".
    # From blog/, it should be "index.html".
    
    # Asset Links
    (r'href="assets/', r'href="../assets/'),
    (r'src="assets/', r'src="../assets/'),
    
    # Specific fix for blog/ links being referenced from pages/
    (r'href="blog/', r'href="../blog/'),
]

for directory in dirs_to_fix:
    if not os.path.exists(directory):
        continue
        
    print(f"Processing directory: {directory}")
    for filename in os.listdir(directory):
        if filename.endswith(".html"):
            filepath = os.path.join(directory, filename)
            
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # Apply standard Level 1 replacements (Parent Directory ..)
            for pattern, replacement in replacements:
                # We use negative lookbehind to ensure we don't fix what's already fixed
                # e.g. don't turn "../index.html" into "../../index.html"
                # Regex logic: Match pattern if it's NOT preceded by "../"
                
                # Simplified approach: Check if it's NOT "../" 
                # We search for the string literal.
                
                # Case 1: href="index.html" -> we want href="../index.html"
                # But we might encounter href="../index.html" already.
                
                regex_pattern = pattern.replace('href="', 'href="(?!\.\./)').replace('src="', 'src="(?!\.\./)')
                
                # Special handling for blog folder self-reference
                if "blog" in directory and "blog/index.html" in pattern:
                     # If we are in blog/, "blog/index.html" should technically be just "index.html" or "root/blog/index.html"
                     # But usually user clicks "Blog" -> "blog/index.html". 
                     # If I am in blog/post.html, href="blog/index.html" looks for blog/blog/index.html -> WRONG.
                     # It should be "index.html".
                     pass
                else:
                    content = re.sub(regex_pattern, replacement.replace('../', '../'), content)

            # Context-specific fixes for Blog Folder specifically
            if "blog" in directory:
                 # Fix the "Blog" link in nav which points to "blog/index.html" usually
                 # Inside blog/, it should point to "index.html" OR "../blog/index.html" (same thing)
                 # But our generic rule made it "../blog/index.html" which is correct.
                 
                 # What about assets? "src="../assets/" came from "src="assets/". Correct.
                 pass

            if content != original_content:
                print(f"Fixed: {filename}")
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)

print("Path fixing complete.")
