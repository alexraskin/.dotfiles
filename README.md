# Dotfiles

Managed with [mise](https://mise.jdx.dev/). `mise.toml` declares:

- `[dotfiles]` — symlinks from `$HOME` into this repo
- `[bootstrap.packages]` / `[bootstrap.brew.taps]` — Homebrew formulae, casks, and Mac App Store apps (replaces the old `Brewfile` workflow)
- `[bootstrap.macos.*]` — macOS defaults (Dock, Finder, keyboard)
- `[tasks.*]` — one-off setup tasks (screencaps dir, wallpaper/screensaver, app restarts)

## Setup

```bash
curl -fsSL https://raw.githubusercontent.com/alexraskin/.dotfiles/main/bin/install.sh | bash
```

This installs Xcode Command Line Tools, Homebrew, and `mise`, clones this repo to `~/.dotfiles`, then runs `mise trust && mise bootstrap` to install packages and symlink dotfiles. Open a new terminal session after it completes.

## Usage

```bash
cd ~/.dotfiles

mise bootstrap                    # install packages + symlink dotfiles
mise bootstrap dotfiles status    # show symlink state for every managed file
mise bootstrap dotfiles apply     # (re)apply dotfile symlinks only

mise run bootstrap                # apply macOS defaults + restart Dock/Finder
mise run macos-wallpaper          # set desktop wallpaper + matching screensaver
```

## Adding a New Config

1. Add the file to a directory in this repo (name doesn't matter, but keep the source path one level deep, e.g. `pkgname/filename` — `mise bootstrap dotfiles apply` doesn't resolve deeper nested source paths correctly).
2. Add an entry to `[dotfiles]` in `mise.toml`:

```toml
"~/.config/newapp/config.toml" = "~/.dotfiles/newapp/config.toml"
```

3. Run `mise bootstrap dotfiles apply`.

## Adding a Package

Add a line to `[bootstrap.packages]` in `mise.toml`:

```toml
"brew:somepackage" = "latest"
"brew-cask:somecask" = "latest"
"mas:123456789" = "latest" # App Name
```

Then run `mise bootstrap`.
