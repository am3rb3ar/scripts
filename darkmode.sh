#!/usr/bin/env bash

# CURRENT=$(gsettings get org.gnome.desktop.interface color-scheme)
#
# if [[ "$CURRENT" == "'prefer-dark'" ]]; then
#   MODE="light"
#   gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
#   gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
# else
#   MODE="dark"
#   gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
#   gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
# fi
#
# hyprctl reload
#

set_theme() {
  local mode=$1  # "dark" or "light"

  if [[ "$mode" == "dark" ]]; then
    local gtk_theme="Orchis-Dark-Compact"
    local color_scheme="prefer-dark"
    local prefer_dark=1
  else
    local gtk_theme="Orchis-Compact"  # or whatever your light variant is
    local color_scheme="prefer-light"
    local prefer_dark=0
  fi

  # gsettings
  gsettings set org.gnome.desktop.interface color-scheme "$color_scheme"
  gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"

  # settings.ini files
  for f in ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini; do
    sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$gtk_theme/" "$f"
    sed -i "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$prefer_dark/" "$f"
  done
}

# Toggle logic
CURRENT=$(gsettings get org.gnome.desktop.interface color-scheme)
if [[ "$CURRENT" == "'prefer-dark'" ]]; then
  set_theme light
else
  set_theme dark
fi

hyprctl reload
