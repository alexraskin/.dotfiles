# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package that symlinks into `$HOME`.

## Setup

```bash
curl -fsSL https://raw.githubusercontent.com/alexraskin/.dotfiles/main/bin/install.sh | bash
```

Open a new terminal session after the script completes.

## Usage

```bash
cd ~/.dotfiles

stow zsh          # stow a single package
stow -D zsh       # remove symlinks
stow -R zsh       # re-stow after changes
```

## Adding a New Config

1. Create a directory mirroring the path relative to `$HOME`:

```bash
mkdir -p newpkg/.config/newapp
mv ~/.config/newapp/config.toml newpkg/.config/newapp/
stow newpkg
```

2. Add the package name to `STOW_PACKAGES` in `bin/install.sh`.
