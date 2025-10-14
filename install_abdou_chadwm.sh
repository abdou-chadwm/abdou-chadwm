#!/bin/bash

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script with sudo."
  exit 1
fi

echo "🔧 Installing required packages..."
apt update
apt install -y build-essential dash x11-utils acpi libxft-dev libimlib2-dev libxinerama-dev pamixer brightnessctl conky-all nitrogen pcmanfm geany 

echo "📁 Syncing .config directories..."
for dir in ~/abdou-chadwm/My-fork-of-arcolinux-chadwm/.config/*; do
    if [ -d "$dir" ]; then
        rsync -a --delete "$dir/" "~/.config/$(basename "$dir")/"
    fi
done

echo "📁 Syncing home-folder directories..."
for dir in ~/abdou-chadwm/My-fork-of-arcolinux-chadwm/home-folder/*; do
    if [ -d "$dir" ]; then
        rsync -a --delete "$dir/" "~/$(basename "$dir")/"
    fi
done

echo "🚚 Moving exec-chadwm binary..."
if [ -f ~/abdou-chadwm/My-fork-of-arcolinux-chadwm/usr/bin/exec-chadwm ]; then
    mv -f ~/abdou-chadwm/My-fork-of-arcolinux-chadwm/usr/bin/exec-chadwm /usr/bin/
else
    echo "⚠️ exec-chadwm not found, skipping."
fi

echo "🚚 Moving chadwm.desktop file..."
if [ -f ~/abdou-chadwm/My-fork-of-arcolinux-chadwm/usr/share/xsessions/chadwm.desktop ]; then
    mv -f ~/abdou-chadwm/My-fork-of-arcolinux-chadwm/usr/share/xsessions/chadwm.desktop /usr/share/xsessions/
else
    echo "⚠️ chadwm.desktop not found, skipping."
fi

echo "🔤 Moving fonts and updating font cache..."
if [ -d ~/abdou-chadwm/My-fork-of-arcolinux-chadwm/fonts ]; then
    mkdir -p ~/.local/share/fonts
    rsync -a ~/abdou-chadwm/My-fork-of-arcolinux-chadwm/fonts/ ~/.local/share/fonts/
    fc-cache -fv
else
    echo "⚠️ fonts directory not found, skipping font install."
fi

echo "🛠️ Building and installing chadwm..."
if [ -d ~/.config/arco-chadwm/chadwm ]; then
    cd ~/.config/arco-chadwm/chadwm || exit 1
    if command -v make >/dev/null 2>&1; then
        make install
    else
        echo "❌ 'make' command not found. Please ensure build-essential is installed."
    fi
else
    echo "⚠️ chadwm source directory not found, skipping build."
fi

echo "✅ All tasks completed."



