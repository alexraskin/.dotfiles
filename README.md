# Dotfiles Setup

This uses a bare git repo with `$HOME` as the work tree. No symlinks needed.

---

## New Machine Setup

The dotfiles repo is private, so setup happens in two phases.

### Phase 1: Bootstrap

On a fresh Mac, run the bootstrap script from its public Gist. It installs
Homebrew and 1Password, configures the SSH agent, and clones this repo:

```bash
curl -fsSL https://gist.githubusercontent.com/alexraskin/GIST_ID/raw/bootstrap.sh | bash
```

> **Note:** Replace `GIST_ID` with the actual Gist ID after creating it at gist.github.com.

The bootstrap script will:

1. Install Xcode Command Line Tools (if missing)
2. Install Homebrew (if missing)
3. Install 1Password (if missing)
4. Configure `~/.ssh/config` to use the 1Password SSH agent
5. Guide you through enabling the SSH agent in 1Password settings
6. Verify GitHub SSH access
7. Clone dotfiles into `~/.dotfiles` (bare repo, files synced to `$HOME`)
8. Hand off to `install.sh` automatically

### Phase 2: Full Install (runs automatically)

`install.sh` is called by bootstrap and handles the rest:

1. Install packages from `~/.Brewfile` via `brew bundle`
2. Install Oh My Zsh (if missing)
3. Install asdf plugins and tool versions from `~/.tool-versions`
4. Link Ghostty config to macOS app support directory
5. Set zsh as the default shell
6. Optionally apply macOS system settings (Finder, Dock, keyboard)
7. Optionally set a custom hostname

After the script completes, open a new terminal session to load your shell config.

---

## Daily Usage

Use `dotfiles` exactly like `git`, from any directory.

```bash
dotfiles status
dotfiles add .zshrc
dotfiles commit -m "Update zshrc"
dotfiles push
dotfiles pull
```
