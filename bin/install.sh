#!/usr/bin/env bash
set -e

DOTFILES_REPO="git@github.com:alexraskin/.dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
STOW_PACKAGES=(zsh git aerospace ghostty)

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
if ! command -v brew &>/dev/null; then
  print_step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  print_ok "Homebrew already installed"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Dotfiles
if [[ ! -d "$DOTFILES_DIR" ]]; then
  print_step "Cloning dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  print_ok "Dotfiles already cloned, pulling latest..."
  git -C "$DOTFILES_DIR" pull origin main
fi

# Brew bundle
print_step "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# Remove existing configs that would conflict with stow
print_step "Removing existing configs before stowing..."
rm -f ~/.zshrc ~/.gitconfig ~/.gitattributes ~/.aerospace.toml


# Stow packages
print_step "Stowing packages..."
cd "$DOTFILES_DIR"
for pkg in "${STOW_PACKAGES[@]}"; do
  stow -v "$pkg"
  print_ok "Stowed $pkg"
done

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  print_step "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  print_ok "Oh My Zsh already installed"
fi

# Powerlevel10k
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  print_step "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  print_ok "Powerlevel10k already installed"
fi



# Default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
  print_step "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
else
  print_ok "zsh is already the default shell"
fi

# Optional extras
echo ""
read -r -p "Apply macOS system settings (keyboard, Finder, Dock)? [y/N] " apply_macos
if [[ "$apply_macos" =~ ^[Yy]$ ]]; then
  print_step "Applying macOS settings..."
  bash "$DOTFILES_DIR/bin/macos-settings.sh"
fi

read -r -p "Set a custom hostname? [y/N] " set_host
if [[ "$set_host" =~ ^[Yy]$ ]]; then
  read -r -p "Enter hostname: " new_hostname
  sudo bash "$DOTFILES_DIR/bin/set-hostname.sh" "$new_hostname"
fi

echo ""
echo "Done! Open a new terminal session to load your shell config."
