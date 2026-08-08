#!/usr/bin/env bash
# Desktop picture + screensaver. Not in the flake: nix-darwin has no clean
# option for either, and both are one-shot settings rather than state to keep.
set -euo pipefail

URL="${1:-https://cdn.alexraskin.com/wallpapers/wp16126074-dragon-anime-4k-wallpapers.jpg}"
WALLPAPER="$HOME/Pictures/wallpaper.jpeg"

echo "==> Downloading wallpaper"
curl -fsSL "$URL" -o "$WALLPAPER"

echo "==> Setting desktop picture"
osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$WALLPAPER\""

echo "==> Setting screensaver"
defaults -currentHost write com.apple.screensaver moduleDict -dict \
  moduleName -string "iLifeSlideshows" \
  path -string "/System/Library/Frameworks/ScreenSaver.framework/PlugIns/iLifeSlideshows.appex" \
  type -int 0
defaults -currentHost write com.apple.screensaver idleTime -int 300
defaults -currentHost write com.apple.screensaver showClock -bool true

echo "Done!"
