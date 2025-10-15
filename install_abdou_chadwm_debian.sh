#!/bin/bash
set -e

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script with sudo."
  exit 1
fi

# Define reusable paths
SRC_DIR="$HOME/abdou-chadwm/My-fork-of-arcolinux-chadwm"
CONFIG_DIR="$HOME/.config"
FONT_DIR="$HOME/.local/share/fonts"

echo "🔧 Installing required packages..."
apt update
apt install -y build-essential dash x11-utils acpi libxft-dev libimlib2-dev libxinerama-dev pamixer brightnessctl conky-all nitrogen pcmanfm geany rsync fontconfig

echo "📁 Syncing .config directories..."
for dir in "$SRC_DIR/.config/"*; do
    if [ -d "$dir" ]; then
        rsync -a --delete "$dir/" "$CONFIG_DIR/$(basename "$dir")/"
    fi
done

echo "📁 Syncing home-folder directories..."
for dir in "$SRC_DIR/home-folder/"*; do
    if [ -d "$dir" ]; then
        rsync -a --delete "$dir/" "$HOME/$(basename "$dir")/"
    fi
done

echo "🚚 Moving exec-chadwm binary..."
if [ -f "$SRC_DIR/usr/bin/exec-chadwm" ]; then
    mv -f "$SRC_DIR/usr/bin/exec-chadwm" /usr/bin/
else
    echo "⚠️ exec-chadwm not found, skipping."
fi

echo "🚚 Moving chadwm.desktop file..."
if [ -f "$SRC_DIR/usr/share/xsessions/chadwm.desktop" ]; then
    mv -f "$SRC_DIR/usr/share/xsessions/chadwm.desktop" /usr/share/xsessions/
else
    echo "⚠️ chadwm.desktop not found, skipping."
fi

echo "🔤 Installing fonts and updating font cache..."
if [ -d "$SRC_DIR/fonts" ]; then
    mkdir -p "$FONT_DIR"
    rsync -a "$SRC_DIR/fonts/" "$FONT_DIR/"
    fc-cache -fv
else
    echo "⚠️ fonts directory not found, skipping font install."
fi

echo "🔤 Syncing additional fonts from .local/share/fonts..."
if [ -d "$SRC_DIR/.local/share/fonts" ]; then
    mkdir -p "$FONT_DIR"
    rsync -a "$SRC_DIR/.local/share/fonts/" "$FONT_DIR/"
    fc-cache -fv
else
    echo "⚠️ .local/share/fonts directory not found, skipping font sync."
fi

echo "🛠️ Building and installing chadwm..."
if [ -d "$CONFIG_DIR/arco-chadwm/chadwm" ]; then
    cd "$CONFIG_DIR/arco-chadwm/chadwm"
    if command -v make >/dev/null 2>&1; then
        make install
    else
        echo "❌ 'make' command not found. Please ensure build-essential is installed."
    fi
else
    echo "⚠️ chadwm source directory not found, skipping build."
fi

echo "✅ All tasks completed."
