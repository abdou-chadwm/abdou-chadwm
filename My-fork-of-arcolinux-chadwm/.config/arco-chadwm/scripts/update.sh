#!/bin/bash
# Run Debian updates in a terminal window and keep it open until you press Enter.

echo "Updating Debian..."
echo
sudo apt update && sudo apt full-upgrade

echo
read -rp "Done. Press Enter to close this window..." _
