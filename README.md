# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
~/.dotfiles/
  zsh/.zshrc
  git/.gitconfig
  git/.gitattributes
  aerospace/.aerospace.toml
  asdf/.tool-versions
  alacritty/.config/alacritty/alacritty.toml
  alacritty/.config/alacritty/catppuccin-macchiato.toml
  ghostty/config.ghostty
  bin/install.sh
  bin/macos-settings.sh
  bin/set-hostname.sh
  bin/update-alacritty-icon.sh
  Brewfile
```

Each top-level directory is a stow package. Running `stow <package>` symlinks its contents into `$HOME`.

## New Machine Setup

Run the install script (macOS only):

```bash
curl -fsSL https://raw.githubusercontent.com/alexraskin/.dotfiles/main/bin/install.sh | bash
```

The script will:

1. Install Xcode Command Line Tools (if missing)
2. Install Homebrew (if missing)
3. Clone dotfiles into `~/.dotfiles`
4. Install packages from `Brewfile` via `brew bundle` (includes stow)
5. Stow all config packages
6. Install Oh My Zsh (if missing)
7. Install asdf plugins and tool versions from `.tool-versions`
8. Link Ghostty config to the macOS Application Support path
9. Set zsh as the default shell
10. Optionally apply macOS system settings, set a hostname, and update the Alacritty icon

Open a new terminal session after the script completes.

## Usage

```bash
cd ~/.dotfiles

# Stow a package
stow zsh

# Stow all packages
stow zsh git aerospace asdf alacritty ghostty

# Remove symlinks for a package
stow -D zsh

# Re-stow after restructuring
stow -R zsh

# Dry run
stow -n -v zsh
```

## Adding a New Config

1. Create a package directory mirroring the path relative to `$HOME`:

```bash
mkdir -p newpkg/.config/newapp
mv ~/.config/newapp/config.toml newpkg/.config/newapp/
```

2. Stow it:

```bash
stow newpkg
```

3. Add the package name to `STOW_PACKAGES` in `bin/install.sh`.