#!/bin/bash
set -euo pipefail

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script with sudo."
  exit 1
fi

# Determine target user and home (the user who invoked sudo)
TARGET_USER="${SUDO_USER:-root}"
TARGET_HOME="$(eval echo "~${TARGET_USER}")"

# Define repository URL (Update this with your actual Git URL)
REPO_URL="https://github.com/YOUR_USERNAME/My-fork-of-arcolinux-chadwm.git"

# Source project and destination paths
SRC_DIR="${TARGET_HOME}/abdou-chadwm/My-fork-of-arcolinux-chadwm"
CONFIG_DIR="${TARGET_HOME}/.config"
FONT_DIR="${TARGET_HOME}/.local/share/fonts"

# Ensure required system tools and development headers are present
echo "🔧 Installing required packages..."
xbps-install -Suy
xbps-install -y base-devel dash xprop acpi libX11-devel libXft-devel imlib2-devel libXinerama-devel pamixer brightnessctl conky nitrogen pcmanfm geany sxhkd arandr nitrogen rsync fontconfig git || {
  echo "❌ Package installation failed."
  exit 1
}

# Clone the repository if it doesn't exist yet
echo "🌐 Checking for source repository..."
if [ ! -d "$SRC_DIR" ]; then
  echo "   Cloning into $SRC_DIR..."
  sudo -u "$TARGET_USER" mkdir -p "$(dirname "$SRC_DIR")"
  sudo -u "$TARGET_USER" git clone "$REPO_URL" "$SRC_DIR" || {
    echo "❌ Git clone failed. Please check the REPO_URL."
    exit 1
  }
else
  echo "   Repository already exists. Pulling latest changes..."
  sudo -u "$TARGET_USER" git -C "$SRC_DIR" pull || echo "⚠️ Could not pull latest changes, continuing anyway."
fi

# Enable safe globbing so empty globs vanish
shopt -s nullglob dotglob

echo "📁 Syncing .config directories..."
if [ -d "$SRC_DIR/.config" ]; then
  sudo -u "$TARGET_USER" mkdir -p "$CONFIG_DIR"
  for dir in "$SRC_DIR/.config/"*; do
    if [ -d "$dir" ]; then
      rsync -a --delete "$dir/" "$CONFIG_DIR/$(basename "$dir")/"
      chown -R "$TARGET_USER":"$TARGET_USER" "$CONFIG_DIR/$(basename "$dir")"
    fi
  done
else
  echo "⚠️ Source .config directory not found, skipping."
fi

echo "📁 Syncing home-folder directories..."
if [ -d "$SRC_DIR/home-folder" ]; then
  for dir in "$SRC_DIR/home-folder/"*; do
    if [ -d "$dir" ]; then
      rsync -a --delete "$dir/" "${TARGET_HOME}/$(basename "$dir")/"
      chown -R "$TARGET_USER":"$TARGET_USER" "${TARGET_HOME}/$(basename "$dir")"
    fi
  done
else
  echo "⚠️ Source home-folder directory not found, skipping."
fi

echo "🚚 Installing exec-chadwm binary..."
if [ -f "$SRC_DIR/usr/bin/exec-chadwm" ]; then
  install -Dm755 "$SRC_DIR/usr/bin/exec-chadwm" /usr/bin/exec-chadwm
else
  echo "⚠️ exec-chadwm not found, skipping."
fi

echo "🚚 Installing chadwm.desktop file..."
if [ -f "$SRC_DIR/usr/share/xsessions/chadwm.desktop" ]; then
  install -Dm644 "$SRC_DIR/usr/share/xsessions/chadwm.desktop" /usr/share/xsessions/chadwm.desktop
else
  echo "⚠️ chadwm.desktop not found, skipping."
fi

echo "🔤 Installing fonts and updating font cache..."
sudo -u "$TARGET_USER" mkdir -p "$FONT_DIR"
if [ -d "$SRC_DIR/fonts" ]; then
  rsync -a "$SRC_DIR/fonts/" "$FONT_DIR/"
fi
if [ -d "$SRC_DIR/.local/share/fonts" ]; then
  rsync -a "$SRC_DIR/.local/share/fonts/" "$FONT_DIR/"
fi
if compgen -G "$FONT_DIR/*" > /dev/null; then
  chown -R "$TARGET_USER":"$TARGET_USER" "$FONT_DIR"
  sudo -u "$TARGET_USER" fc-cache -fv || echo "⚠️ fc-cache failed or not available."
else
  echo "⚠️ No fonts copied, skipping fc-cache."
fi

echo "🛠️ Building and installing chadwm..."
if [ -d "${CONFIG_DIR}/arco-chadwm/chadwm" ]; then
  pushd "${CONFIG_DIR}/arco-chadwm/chadwm" >/dev/null
  if command -v make >/dev/null 2>&1; then
    make clean   # Clean any old builds first
    make install # Install as root
    make clean   # Clean up root-owned object files so the user can recompile later
  else
    echo "❌ 'make' command not found. Please ensure base-devel is installed."
  fi
  popd >/dev/null
else
  echo "⚠️ chadwm source directory not found under ${CONFIG_DIR}/arco-chadwm/chadwm, skipping build."
fi

echo "✅ All tasks completed."
