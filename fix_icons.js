const fs = require('fs');
const path = 'c:/Users/SACHIN/Downloads/new_TWC/new_TWC/about.html';
let content = fs.readFileSync(path, 'utf8');

const frameworksIcon = `<div class="icon">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                                stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                            </svg>
                                        </div>`;

const careersIcon = `<div class="icon">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                                stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                                                <circle cx="9" cy="7" r="4" />
                                                <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                                                <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                                            </svg>
                                        </div>`;

// Use regex that is less sensitive to exact emoji representation
content = content.replace(/<div class="icon">ðŸ &mdash;ï¸ <\/div>/g, frameworksIcon);
content = content.replace(/<div class="icon">ðŸ¤ <\/div>/g, careersIcon);

fs.writeFileSync(path, content, 'utf8');
console.log('Successfully updated about.html icons');
