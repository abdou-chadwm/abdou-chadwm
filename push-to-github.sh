#!/bin/bash

# 1. Check if we can talk to GitHub via SSH
ssh -T git@github.com &>/dev/null
if [ $? -ne 1 ]; then
    echo "󰛵 SSH Connection to GitHub failed. Check your keys!"
    exit 1
fi

# 2. Navigate to your chadwm directory
cd /home/abdou/abdou-chadwm/ || exit

# 3. Standard Git Workflow
git add .

# Prompt for a commit message (optional, or use a default)
read -p "Enter commit message (default: 'update'): " msg
if [ -z "$msg" ]; then
    msg="update $(date +'%Y-%m-%d %H:%M')"
fi

git commit -m "$msg"

# 4. Push to the main branch
echo "󰊢 Pushing to GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo " Successfully pushed to abdou-chadwm!"
else
    echo " Push failed."
fi
