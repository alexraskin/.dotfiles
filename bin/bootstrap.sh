#!/usr/bin/env bash
set -e

DOTFILES_REPO="git@github.com:alexraskin/.dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

print_step() { echo "==> $1"; }
print_ok()   { echo "    [ok] $1"; }

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

# 1Password and CLI
if [[ ! -d "/Applications/1Password.app" ]]; then
  print_step "Installing 1Password..."
  brew install --cask 1password
else
  print_ok "1Password already installed"
fi
if ! command -v op &>/dev/null; then
  print_step "Installing 1Password CLI..."
  brew install 1password-cli
else
  print_ok "1Password CLI already installed"
fi

# SSH config for 1Password agent
SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if ! grep -q "1password/agent.sock" "$SSH_CONFIG" 2>/dev/null; then
  print_step "Adding 1Password SSH agent to ~/.ssh/config..."
  cat >> "$SSH_CONFIG" <<'EOF'

Host *
  IdentityAgent "~/.1password/agent.sock"
EOF
  chmod 600 "$SSH_CONFIG"
  print_ok "SSH config updated"
else
  print_ok "SSH config already configured for 1Password agent"
fi

# Guide 1Password SSH agent setup
echo ""
echo "==> Action required: Enable 1Password SSH Agent"
echo ""
echo "    1. Open 1Password and sign in to your account"
echo "    2. Open Settings (⌘,) → Developer"
echo "    3. Enable 'Use the SSH Agent'"
echo "    4. Authorize the SSH key you use for GitHub"
echo "    5. In GitHub: Settings → SSH keys → make sure your key is listed"
echo ""
read -r -p "    Press Enter once 1Password SSH agent is running and your key is authorized..."

# Point SSH at 1Password agent socket for the rest of this script
export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"

# Verify SSH access
print_step "Testing GitHub SSH access..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  print_ok "GitHub SSH access confirmed"
else
  echo "    ERROR: Could not authenticate with GitHub via SSH." >&2
  echo "    Make sure your SSH key is added to GitHub and 1Password SSH agent is running." >&2
  exit 1
fi

# Clone dotfiles
if [[ ! -d "$DOTFILES_DIR" ]]; then
  print_step "Cloning dotfiles..."
  TMPDIR=$(mktemp -d)
  git clone --separate-git-dir="$DOTFILES_DIR" "$DOTFILES_REPO" "$TMPDIR"
  rsync --recursive --exclude '.git' "$TMPDIR/" "$HOME/"
  rm -rf "$TMPDIR"
  git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config --local status.showUntrackedFiles no
  print_ok "Dotfiles cloned"
else
  print_ok "Dotfiles already present, skipping clone"
fi

# Hand off to install.sh for the rest
print_step "Running install.sh..."
bash "$HOME/bin/install.sh"
