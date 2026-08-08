# .dotfiles

macOS system configuration, managed declaratively with [nix-darwin](https://github.com/LnL7/nix-darwin), [home-manager](https://github.com/nix-community/home-manager), and [nix-homebrew](https://github.com/zhaofengli/nix-homebrew). One flake describes the whole machine: packages, Homebrew casks, macOS defaults, git config, and dotfiles.

## Layout

```
flake.nix                  inputs + the darwinConfigurations output
lib/mkSystem.nix           host factory
hosts/                     system level (runs as root)
  nix-settings.nix         nix + nixpkgs config, stateVersion
  darwin/
    settings.nix           entry point — imports the rest
    macos-defaults.nix     Dock, Finder, keyboard
    homebrew.nix           nix-homebrew + brews, casks, masApps
    aerospace.nix          window manager + its launchd agent
    home-manager.nix       home-manager wiring
home/                      user level — packages, dotfile symlinks
apps/                      per-app config; config.nix imports each module
  git/  mise/  zsh/  p10k/  ghostty/  claude/
```

`hosts/` splits by platform, not by machine — a host is one `mkSystem` call in `flake.nix`. Each app owns a directory under `apps/` holding its config file and, where it has one, the nix module that manages it.

## Setup

```bash
curl -fsSL https://raw.githubusercontent.com/alexraskin/.dotfiles/main/bin/install.sh | bash
```

Installs Xcode Command Line Tools and Nix, clones this repo to `~/.dotfiles`, and runs the first activation. Everything else comes from the flake. `bin/wallpaper.sh` sets the desktop picture and screensaver separately — nix-darwin has no clean option for either.

## Usage

```bash
cd ~/.dotfiles

darwin-rebuild build --flake .#mba         # evaluate + build, change nothing
sudo darwin-rebuild switch --flake .#mba   # build + activate

nix flake update                           # bump all inputs
nix flake update nixpkgs                   # bump one
```

## Adding things

**Config file** — put it in `apps/<app>/`, add a line to `home/dotfiles.nix`. These are out-of-store symlinks, so edits take effect without a rebuild.

**Package** — `home/packages.nix` for CLI tools from nixpkgs, `hosts/darwin/homebrew.nix` for GUI apps and brew-only formulae.

**App module** — `apps/<app>/<app>.nix`, imported from `apps/config.nix`.

Then `sudo darwin-rebuild switch --flake .#mba`.

## Homebrew

`onActivation.cleanup = "zap"` means anything not listed in `homebrew.nix` gets uninstalled on the next activation — a manual `brew install` lasts only until you switch. `autoUpdate` and `upgrade` are both on, so a switch already runs `brew update` and upgrades everything outdated; there is no separate update step.

```bash
brew search <name>       # find the exact cask/formula name
brew bundle list --all   # what the flake declares (defaults to formulae only)
brew bundle check        # is the system in sync?
brew outdated            # what the next switch will upgrade
mas search <name>        # App Store IDs for masApps
```

If you ever add a third-party tap: Homebrew 6 refuses untrusted taps, and `cleanup` rewrites `~/.homebrew/trust.json` from the Brewfile on every activation. So the only durable way to trust one is a **fully-qualified** name in `casks`/`brews` — a manual `brew trust` or a `nix-homebrew.trust` block gets wiped mid-activation. Fully-qualifying a `brew` (not a `cask`) also makes cleanup uninstall it, so check with `brew bundle cleanup` first.

## Gotchas

**`~/.zshrc` is generated** by `apps/zsh/zsh.nix` — don't edit it, don't symlink it. Order is set with `lib.mkOrder`: `~/.zshrc.local` and the p10k instant prompt at 500 (before anything that can print), oh-my-zsh at 800, p10k theme at 900, `~/.p10k.zsh` last. Functions live in `apps/zsh/shell-functions.sh` as plain zsh so they need no `''${…}` escaping — the tradeoff is that editing them needs a rebuild.

**`history.share` is pinned false.** home-manager defaults it true, which the old `.zshrc` never did and which conflicts with `INC_APPEND_HISTORY_TIME`.

**AeroSpace is fully declarative.** `hosts/darwin/aerospace.nix` generates the TOML into the store and launchd runs it, so there is no `~/.aerospace.toml`. `start-at-login` must stay unset — the module asserts on it.
