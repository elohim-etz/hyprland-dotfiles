#!/usr/bin/env bash
set -euo pipefail

info() {
    echo "ℹ️ $1"
}

warn() {
    echo "⚠️ $1" >&2
}

error() {
    echo "❌ $1" >&2
    exit 1
}

# Check if SDDM is installed
if ! command -v sddm &>/dev/null; then
    info "SDDM is not installed. Installing now..."
    if ! sudo pacman -S --noconfirm sddm; then
        error "Failed to install SDDM"
    fi
fi

# Configure SDDM
info "Configuring SDDM as the display manager..."

# Enable SDDM service
if ! sudo systemctl enable sddm --now; then
    error "Failed to enable SDDM service"
fi

# Create SDDM config directory
sudo mkdir -p /etc/sddm.conf.d

# Check if theme config already exists with correct settings
THEME_CONFIG="/etc/sddm.conf.d/theme.conf"
if [ -f "$THEME_CONFIG" ]; then
    if grep -q "Current=sugar-candy" "$THEME_CONFIG"; then
        info "Sugar Candy theme already configured. Skipping configuration."
    else
        info "Updating SDDM theme configuration..."
        sudo tee "$THEME_CONFIG" >/dev/null <<EOF
[Theme]
Current=sugar-candy
EOF
    fi
else
    info "Setting Sugar Candy theme..."
    sudo tee "$THEME_CONFIG" >/dev/null <<EOF
[Theme]
Current=sugar-candy
EOF
fi

# Check if Sugar Candy theme is installed
if pacman -Qi sddm-theme-sugar-candy &>/dev/null; then
    info "Sugar Candy theme already installed."
else
    info "Installing Sugar Candy theme..."
    
    # Check if paru is available
    if ! command -v paru &>/dev/null; then
        warn "paru not found. Cannot install AUR package sddm-theme-sugar-candy."
        warn "You can install it manually later with: paru -S sddm-theme-sugar-candy"
    else
        if paru -S --noconfirm sddm-theme-sugar-candy; then
            info "Sugar Candy theme installed successfully."
        else
            warn "Could not install Sugar Candy theme. SDDM will use the default theme."
        fi
    fi
fi

# Verify theme directory exists
SUGAR_CANDY_DIR="/usr/share/sddm/themes/sugar-candy"
if [ -d "$SUGAR_CANDY_DIR" ]; then
    info "Sugar Candy theme directory found at $SUGAR_CANDY_DIR"
else
    warn "Sugar Candy theme directory not found. Theme may not work properly."
fi

info "SDDM configured successfully."