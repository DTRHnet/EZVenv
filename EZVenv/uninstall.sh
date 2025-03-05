#!/bin/bash

echo "🔧 Uninstalling EZVenv..."

INSTALL_DIR="$HOME/.EZVenv"
PROFILE_FILE="$HOME/.bashrc"

if [[ -d "$INSTALL_DIR" ]]; then
    echo "Removing EZVenv directory..."
    rm -rf "$INSTALL_DIR"
fi

echo "Removing EZVenv from PATH in $PROFILE_FILE..."
sed -i '/.EZVenv/d' "$PROFILE_FILE"

echo "✅ EZVenv uninstalled successfully. Restart your terminal for changes to take effect."
