# .dotfiles

macOS system configuration, managed declaratively with [nix-darwin](https://github.com/LnL7/nix-darwin), [home-manager](https://github.com/nix-community/home-manager), and [nix-homebrew](https://github.com/zhaofengli/nix-homebrew). One flake describes the whole machine: packages, Homebrew casks, macOS defaults, hostname, git config, and dotfile symlinks.

## Layout

```
flake.nix                          inputs + the `mba` darwin configuration
nix/darwin/                        system level (runs as root)
  default.nix                      nix settings, nix-homebrew, home-manager wiring
  homebrew.nix                     taps, brews, casks
  settings.nix                     macOS defaults (Dock, Finder, keyboard), Touch ID sudo
nix/home/                          user level (home-manager)
  packages.nix                     CLI tools from nixpkgs
  git.nix                          git config, global ignores/attributes, signing
  dotfiles.nix                     symlinks from $HOME into this repo
  mise.nix                         mise + zsh integration
nix/hosts/mba/               host-specific overrides
```

Config files themselves (`zsh/`, `ghostty/`, `aerospace/`, `p10k/`, `ata/`, `claude/`) live at the repo root and are symlinked into place by `nix/home/dotfiles.nix`.

Oh My Zsh and Powerlevel10k come from nixpkgs (`nix/home/packages.nix`), so `~/.zshrc` sources them out of `/etc/profiles/per-user/$USER/share`. `$ZSH` is read-only in the store — hence the explicit `ZSH_CACHE_DIR`, and the theme being sourced directly instead of set via `ZSH_THEME`.

## Setup

```bash
curl -fsSL https://raw.githubusercontent.com/alexraskin/.dotfiles/main/bin/install.sh | bash
```

The script does only what can't be declared in the flake: installs Xcode Command Line Tools and Nix, clones this repo to `~/.dotfiles`, and runs the first activation. Everything else — Homebrew itself (via nix-homebrew), packages, casks, macOS defaults, dotfile symlinks — comes from `darwin-rebuild switch --flake .#mba`. Open a new terminal session after it completes.

`bin/wallpaper.sh` sets the desktop picture and screensaver; it's separate because nix-darwin has no clean option for either.

## Usage

```bash
cd ~/.dotfiles

darwin-rebuild build --flake .#mba    # evaluate + build, change nothing
sudo darwin-rebuild switch --flake .#mba  # build + activate

nix flake update                             # bump all inputs
nix flake update nixpkgs                     # bump one input
```

`darwin-rebuild build` leaves a `result` symlink in the repo — safe to delete.

## Adding a Config File

1. Add the file to a directory in this repo, e.g. `newapp/config.toml`.
2. Add an entry to `nix/home/dotfiles.nix`:

```nix
xdg.configFile."newapp/config.toml".source = link "newapp/config.toml";
# or, for a dotfile directly in $HOME:
home.file.".newapprc".source = link "newapp/.newapprc";
```

3. `sudo darwin-rebuild switch --flake .#mba`

These are out-of-store symlinks (`mkOutOfStoreSymlink`), so edits to the file in this repo take effect immediately without a rebuild.

## Adding a Package

Prefer nixpkgs; use Homebrew for GUI apps and anything not packaged for nix.

```nix
# nix/home/packages.nix — CLI tools
home.packages = with pkgs; [ ripgrep jq gh ];

# nix/darwin/homebrew.nix — GUI apps + brew-only formulae
casks = [ "ghostty" ];
brews = [ "mas" ];
```

Then `sudo darwin-rebuild switch --flake .#mba`.

`homebrew.onActivation.cleanup = "zap"` means anything installed via Homebrew but *not* listed in `homebrew.nix` gets uninstalled (and its config zapped) on the next activation. The Brewfile is the source of truth.

## Third-Party Tap Trust

Homebrew 6.0 enables `HOMEBREW_REQUIRE_TAP_TRUST`, refusing to load formulae or casks from non-official taps until they are explicitly trusted. Untrusted entries abort activation — including the `brew cleanup` that runs at the end of the bundle step.

**The Brewfile is the only durable source of trust here.** Because `onActivation.cleanup` implies `--force-cleanup`, every activation runs `Homebrew::Trust.replace!` (`bundle/subcommand/cleanup.rb`), which overwrites `~/.homebrew/trust.json` with exactly the entries the Brewfile declares. Anything added out of band — a manual `brew trust`, or the `nix-homebrew.trust` block in `nix/darwin/default.nix` — is wiped mid-activation, and the `brew cleanup` that runs immediately after then fails on the now-untrusted item.

Bundle only emits a trust entry for a **fully-qualified** name, which is why the cask is listed as:

```nix
casks = [ "nikitabobko/tap/aerospace" ];
```

Fully-qualifying a `brew` has a side effect that a `cask` doesn't: `kept_formulae` compares the Brewfile name against each installed formula's `full_name`, so `brew "user/tap/foo"` will not match an installed `foo` and cleanup uninstalls it. Check with `brew bundle cleanup --file=<brewfile>` (no `--force` — it only lists) before fully-qualifying a formula.

Tap-wide trust is also possible (`taps = [ { name = "user/tap"; trusted = true; } ]`), but it covers all of that tap's current *and future* contents.
