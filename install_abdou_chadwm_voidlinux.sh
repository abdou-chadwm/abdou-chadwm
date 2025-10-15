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

# Source project and destination paths (adjust if needed)
SRC_DIR="${TARGET_HOME}/abdou-chadwm/My-fork-of-arcolinux-chadwm"
CONFIG_DIR="${TARGET_HOME}/.config"
FONT_DIR="${TARGET_HOME}/.local/share/fonts"

# Ensure required system tools are present or install them
echo "🔧 Installing required packages..."
xbps-install -Suy
xbps-install -y base-devel dash xprop acpi libXft imlib2 libXinerama pamixer brightnessctl conky nitrogen pcmanfm geany rsync fontconfig || {
  echo "❌ Package installation failed."
  exit 1
}

# Enable safe globbing so empty globs vanish
shopt -s nullglob dotglob

echo "📁 Syncing .config directories..."
if [ -d "$SRC_DIR/.config" ]; then
  mkdir -p "$CONFIG_DIR"
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
mkdir -p "$FONT_DIR"
if [ -d "$SRC_DIR/fonts" ]; then
  rsync -a "$SRC_DIR/fonts/" "$FONT_DIR/"
fi
if [ -d "$SRC_DIR/.local/share/fonts" ]; then
  rsync -a "$SRC_DIR/.local/share/fonts/" "$FONT_DIR/"
fi
if compgen -G "$FONT_DIR/*" > /dev/null; then
  chown -R "$TARGET_USER":"$TARGET_USER" "$FONT_DIR"
  fc-cache -fv || echo "⚠️ fc-cache failed or not available."
else
  echo "⚠️ No fonts copied, skipping fc-cache."
fi

echo "🛠️ Building and installing chadwm (if source present)..."
if [ -d "${CONFIG_DIR}/arco-chadwm/chadwm" ]; then
  pushd "${CONFIG_DIR}/arco-chadwm/chadwm" >/dev/null
  if command -v make >/dev/null 2>&1; then
    make install
  else
    echo "❌ 'make' command not found. Please ensure base-devel is installed."
  fi
  popd >/dev/null
else
  echo "⚠️ chadwm source directory not found under ${CONFIG_DIR}/arco-chadwm/chadwm, skipping build."
fi

echo "✅ All tasks completed."
