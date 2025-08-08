#!/bin/bash

echo "Attempting to create GitHub repository..."

# Try using gh with stored auth
gh auth status 2>/dev/null

# Create the repository
gh repo create Calemai --public --source=. --push --description "Calendar-focused task management iOS app" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Repository created and pushed successfully!"
    echo "View at: https://github.com/jadewii/Calemai"
else
    echo "Manual steps required:"
    echo "1. The GitHub new repo page should be open in Safari"
    echo "2. Fill in:"
    echo "   - Repository name: Calemai"
    echo "   - Description: Calendar-focused task management iOS app"
    echo "   - Set to Public"
    echo "   - DO NOT add README, .gitignore, or license"
    echo "3. Click 'Create repository'"
    echo "4. Then run: git push -u origin main"
fi