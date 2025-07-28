#!/usr/bin/env bash

set -euo pipefail

info() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

info "Checking if Catppuccin GRUB theme is already installed..."

THEME_DIR="/usr/share/grub/themes/catppuccin-mocha-grub-theme"
THEME_FILE="$THEME_DIR/theme.txt"
THEME_REPO_DIR="$HOME/catppuccin-grub"

# Check if theme is already properly installed
if [ -f "$THEME_FILE" ]; then
    info "Catppuccin GRUB theme already exists. Skipping clone and copy."
else
    info "Installing Catppuccin GRUB theme..."
    
    # Clean up any existing repo directory
    rm -rf "$THEME_REPO_DIR"
    
    # Clone with error handling
    if ! git clone https://github.com/catppuccin/grub.git "$THEME_REPO_DIR"; then
        error "Failed to clone Catppuccin GRUB theme repository"
    fi
    
    # Check if source files exist
    if [ ! -d "$THEME_REPO_DIR/src" ]; then
        error "Theme source directory not found in cloned repository"
    fi
    
    # Create theme directory and copy files with error handling
    if ! sudo mkdir -p /usr/share/grub/themes; then
        error "Failed to create GRUB themes directory"
    fi
    
    if ! sudo cp -r "$THEME_REPO_DIR/src/"* /usr/share/grub/themes/; then
        error "Failed to copy theme files"
    fi
    
    # Clean up
    rm -rf "$THEME_REPO_DIR"
    
    info "Catppuccin GRUB theme installed successfully."
fi

# Ensure GRUB_THEME is set properly in /etc/default/grub
if grep -q "^GRUB_THEME=" /etc/default/grub; then
    CURRENT_THEME=$(grep "^GRUB_THEME=" /etc/default/grub | cut -d '"' -f2)
    if [ "$CURRENT_THEME" != "$THEME_FILE" ]; then
        info "Updating GRUB_THEME in /etc/default/grub..."
        if ! sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$THEME_FILE\"|" /etc/default/grub; then
            error "Failed to update GRUB_THEME in /etc/default/grub"
        fi
    else
        info "GRUB_THEME already set correctly. Skipping update."
    fi
else
    info "Adding GRUB_THEME to /etc/default/grub..."
    if ! echo "GRUB_THEME=\"$THEME_FILE\"" | sudo tee -a /etc/default/grub > /dev/null; then
        error "Failed to add GRUB_THEME to /etc/default/grub"
    fi
fi

# Always regenerate GRUB config to ensure theme is applied
info "Regenerating GRUB configuration..."
if ! sudo grub-mkconfig -o /boot/grub/grub.cfg; then
    error "Failed to regenerate GRUB configuration"
fi

info "GRUB theme setup completed successfully!"