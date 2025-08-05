#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
# 🚀 Hyprland Dotfiles Installer for Arch Linux
# Author: NAVEEN
# Repo: https://github.com/elohim-etz/Dotfiles
# ──────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_DIR="$HOME/.local/share/wallpapers"
CORE_LIST="$SCRIPT_DIR/package_core.lst"
EXTRA_LIST="$SCRIPT_DIR/package_extra.lst"

echo -e "\n🔧 Starting Hyprland setup..."
echo "📁 Dotfiles directory: $SCRIPT_DIR"

# ──────────────────────────────────────────────────────────────
# 🔄 Update System
echo -e "\n🔄 Updating system..."
sudo pacman -Syu --noconfirm

# ──────────────────────────────────────────────────────────────
# 📦 Install Paru if not present
if command -v paru &>/dev/null; then
    echo "✅ paru already installed."
else
    echo "📦 Installing paru..."
    sudo pacman -S --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
    cd /tmp/paru-bin
    makepkg -si --noconfirm
    rm -rf /tmp/paru-bin
    echo "✅ paru installed successfully."
fi

# ──────────────────────────────────────────────────────────────
# 📦 Install Core and AUR Packages

read_package_list() {
    grep -vE '^\s*#|^\s*$' "$1" || true
}

if [[ -f "$CORE_LIST" ]]; then
    CORE_PACKAGES=$(read_package_list "$CORE_LIST")
    if [[ -n "$CORE_PACKAGES" ]]; then
        echo "📦 Installing core packages..."
        sudo pacman -S --needed --noconfirm $CORE_PACKAGES
    fi
fi

if [[ -f "$EXTRA_LIST" ]]; then
    EXTRA_PACKAGES=$(read_package_list "$EXTRA_LIST")
    if [[ -n "$EXTRA_PACKAGES" ]]; then
        echo "📦 Installing AUR packages..."
        paru -S --needed --noconfirm $EXTRA_PACKAGES
    fi
fi

# ──────────────────────────────────────────────────────────────
# 🌀 Stow Dotfiles
echo -e "\n📂 Stowing dotfiles..."

cd "$SCRIPT_DIR"

echo -e "\n⚠️ WARNING: This will overwrite existing dotfiles:"
echo "  - ~/.zshrc"
echo "  - ~/.tmux.conf"
echo "  - ~/.config/hypr/"
echo "  - And other config files"
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

rm -rf ~/.config/hypr/*

stow --adopt -t ~ zsh
stow --adopt -t ~ tmux
stow --adopt -t ~ hypr
stow --adopt -t ~ config
stow --adopt -t ~ local
stow --adopt -t ~ nvim

# ──────────────────────────────────────────────────────────────
# 🐚 Set Zsh as default shell
ZSH_PATH="$(command -v zsh)"
if ! grep -qxF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi
chsh -s "$ZSH_PATH"
echo "ℹ️ Please log out and log back in for Zsh to take effect."

# ──────────────────────────────────────────────────────────────
# ⛓️ Make Scripts Executable
chmod +x /home/elohim/dotfiles/local/.local/bin/MyScripts/*
chmod +x ./scripts/*

# ──────────────────────────────────────────────────────────────
# 🖼️ Download Wallpapers
echo -e "\n🖼️ Downloading wallpapers..."

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    git clone --depth=1 https://github.com/elohim-etz/Walls.git "$WALLPAPER_DIR"
else
    git -C "$WALLPAPER_DIR" pull --ff-only
fi

echo "Wallpapers installed to $WALLPAPER_DIR"

# ──────────────────────────────────────────────────────────────
# 🧩 Enable Essential Services
echo -e "\n🔧 Enabling essential services..."
sudo systemctl enable --now bluetooth NetworkManager systemd-resolved

# ──────────────────────────────────────────────────────────────

# 🖥️ Configure tmux
mkdir -p ~/.config/tmux/plugins/catppuccin
git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux

# ──────────────────────────────────────────────────────────────
# 🖥️ Configure SDDM
"$SCRIPT_DIR/scripts/sddm.sh"

# ──────────────────────────────────────────────────────────────
# 🧵 Apply GRUB Theme
"$SCRIPT_DIR/scripts/grubtheme.sh"

# ──────────────────────────────────────────────────────────────
# ✅ Done
echo -e "\n✅ Installation Complete! Please reboot to apply all changes."
