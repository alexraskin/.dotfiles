# Dotfiles Setup

This uses a bare git repo with `$HOME` as the work tree. No symlinks needed.

---

## New Machine Setup

Run the one-shot install script (macOS only):

```bash
curl -fsSL https://raw.githubusercontent.com/alexraskin/.dotfiles/main/bin/install.sh | bash
```

The script will:

1. Install Xcode Command Line Tools (if missing)
2. Install Homebrew (if missing)
3. Clone dotfiles into `~/.dotfiles` (bare repo, files synced to `$HOME`)
4. Install packages from `~/.Brewfile` via `brew bundle`
5. Install Oh My Zsh (if missing)
6. Install asdf plugins and tool versions from `~/.tool-versions`
7. Set zsh as the default shell
8. Optionally apply macOS system settings (Finder, Dock, keyboard)
9. Optionally set a custom hostname

After the script completes, open a new terminal session to load your shell config.

---

## Daily Usage

Use `dotfiles` exactly like `git`, from any directory.

```bash
dotfiles status
dotfiles add .vimrc
dotfiles commit -m "Update vimrc"
dotfiles push
dotfiles pull
```
