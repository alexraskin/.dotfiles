#!/usr/bin/env bash
set -e

DOTFILES_REPO="git@github.com:alexraskin/.dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

print_step() { echo "==> $1"; }
print_ok()   { echo "    [ok] $1"; }

# macOS only
if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script is macOS only." >&2
  exit 1
fi

# Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  print_step "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "    Re-run this script after the installation completes."
  exit 0
else
  print_ok "Xcode Command Line Tools already installed"
fi

# Homebrew
_brew_shellenv() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

if ! command -v brew &>/dev/null; then
  print_step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  _brew_shellenv
else
  print_ok "Homebrew already installed"
  _brew_shellenv
fi

# Dotfiles (bare git repo)
if [[ ! -d "$DOTFILES_DIR" ]]; then
  print_step "Cloning dotfiles..."
  # Clone to a temp dir, then rsync to handle any existing config files
  TMPDIR=$(mktemp -d)
  git clone --separate-git-dir="$DOTFILES_DIR" "$DOTFILES_REPO" "$TMPDIR"
  rsync --recursive --verbose --exclude '.git' "$TMPDIR/" "$HOME/"
  rm -rf "$TMPDIR"
  git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config --local status.showUntrackedFiles no
else
  print_ok "Dotfiles already cloned, pulling latest..."
  git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" pull origin main
fi

# Brew bundle
print_step "Installing packages from Brewfile..."
brew bundle --file="$HOME/.Brewfile"

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  print_step "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  print_ok "Oh My Zsh already installed"
fi

# asdf plugins and versions
if command -v asdf &>/dev/null && [[ -f "$HOME/.tool-versions" ]]; then
  print_step "Installing asdf plugins and tool versions..."
  while IFS=' ' read -r plugin version; do
    [[ -z "$plugin" || "$plugin" == \#* ]] && continue
    if ! asdf plugin list 2>/dev/null | grep -q "^${plugin}$"; then
      echo "    Adding asdf plugin: $plugin"
      asdf plugin add "$plugin" || true
    fi
    echo "    Installing $plugin $version"
    asdf install "$plugin" "$version" || true
  done < "$HOME/.tool-versions"
  asdf reshim || true
else
  print_ok "Skipping asdf (not installed or no .tool-versions)"
fi

# Ghostty config symlink (macOS uses a non-XDG path by default)
GHOSTTY_MACOS_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
GHOSTTY_XDG_CONFIG="$HOME/.config/ghostty/config.ghostty"
if [[ -d "$(dirname "$GHOSTTY_MACOS_DIR")" ]]; then
  mkdir -p "$GHOSTTY_MACOS_DIR"
  if [[ ! -L "$GHOSTTY_MACOS_DIR/config.ghostty" ]]; then
    print_step "Linking Ghostty config..."
    ln -sf "$GHOSTTY_XDG_CONFIG" "$GHOSTTY_MACOS_DIR/config.ghostty"
    print_ok "Ghostty config linked"
  else
    print_ok "Ghostty config already linked"
  fi
fi

# Default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
  print_step "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
else
  print_ok "zsh is already the default shell"
fi

# macOS settings (optional)
echo ""
read -r -p "Apply macOS system settings (keyboard, Finder, Dock)? [y/N] " apply_macos
if [[ "$apply_macos" =~ ^[Yy]$ ]]; then
  print_step "Applying macOS settings..."
  bash "$HOME/bin/macos-settings.sh"
fi

# Hostname (optional)
read -r -p "Set a custom hostname? [y/N] " set_host
if [[ "$set_host" =~ ^[Yy]$ ]]; then
  bash "$HOME/bin/set-hostname.sh"
fi

echo ""
echo "Done! Open a new terminal session to load your shell config."
