#!/usr/bin/env bash

# Theme settings
GTK_THEME='catppuccin-mocha-blue-standard+default'
ICON_THEME='Tela-circle-dracula'
CURSOR_THEME='Bibata-Modern-Ice'
FONT_NAME='Cantarell 10'
COLOR_SCHEME='prefer-dark'

# GSettings command base
GSET="gsettings set org.gnome.desktop.interface"

apply_themes() {
    $GSET gtk-theme "$GTK_THEME"
    $GSET icon-theme "$ICON_THEME"
    $GSET cursor-theme "$CURSOR_THEME"
    $GSET font-name "$FONT_NAME"
    $GSET color-scheme "$COLOR_SCHEME"
}

apply_themes
