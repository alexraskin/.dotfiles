# .dotfiles

macOS system configuration, managed declaratively with [nix-darwin](https://github.com/LnL7/nix-darwin), [home-manager](https://github.com/nix-community/home-manager), and [nix-homebrew](https://github.com/zhaofengli/nix-homebrew). One flake describes the whole machine: packages, Homebrew casks, macOS defaults, hostname, git config, and dotfile symlinks.

## Layout

```
flake.nix                    inputs + the darwinConfigurations output
lib/mkSystem.nix             host factory — assembles the module list for a host
hosts/                       system level (runs as root)
  nix-settings.nix           nix + nixpkgs config, stateVersion, revision
  darwin/
    settings.nix             darwin entry point: imports the rest, user, PATH
    macos-defaults.nix       Dock, Finder, keyboard, login window
    homebrew.nix             nix-homebrew + taps, brews, casks
    aerospace.nix            AeroSpace window manager + its launchd agent
    home-manager.nix         home-manager wiring
home/                        user level (home-manager)
  default.nix                imports packages, dotfiles, and apps/config.nix
  packages.nix               CLI tools from nixpkgs
  dotfiles.nix               symlinks from $HOME into apps/
apps/                        per-application config
  config.nix                 imports each app module
  git/git.nix                git config, global ignores/attributes, signing
  mise/mise.nix              mise + zsh integration
  zsh/zsh.nix                generates ~/.zshrc: omz, p10k, history, aliases
  zsh/shell-functions.sh     shell functions, sourced from the store
  p10k/.p10k.zsh
  ghostty/config
  claude/settings.json
```

Each app owns a directory under `apps/` holding its config file and, where it has one, the nix module that manages it. Raw config files are symlinked into `$HOME` by `home/dotfiles.nix`; nix modules are pulled in through `apps/config.nix`.

`hosts/` splits by platform, not by machine — there is no per-host directory, since with a single Mac it would only hold a hostname. A host is one `mkSystem` call in `flake.nix`:

```nix
darwinConfigurations."mba" = mkSystem "mba" {
  system = "aarch64-darwin";
  user = "alex";
  hostname = "alexs-mba";
};
```

A second Mac that shares this config is another such call. One that genuinely diverges gets a `hosts/<name>/configuration.nix` added back to the module list in `lib/mkSystem.nix`.

## Zsh

`~/.zshrc` is **generated** by home-manager from `apps/zsh/zsh.nix` — do not edit it, and do not add it to `dotfiles.nix`. Oh My Zsh, Powerlevel10k, zsh-autosuggestions and zsh-syntax-highlighting all come from nixpkgs through that module; home-manager writes a `~/.zshenv` that points `$ZSH` at the store and `ZSH_CACHE_DIR` at `~/.cache/oh-my-zsh`, so nothing needs `pathsToLink` and nothing is read-only.

Ordering inside the generated file is controlled by `lib.mkOrder`, and three positions matter:

| order | what |
| --- | --- |
| 500 | `~/.zshrc.local`, then the p10k instant prompt — must precede all output |
| 800 / 900 | oh-my-zsh, then the p10k theme — the theme has to load second |
| 1500 | `~/.p10k.zsh` — last, after syntax highlighting at 1200 |

Anything that can print or prompt has to go at 500 or it will break the instant prompt.

Shell functions live in `apps/zsh/shell-functions.sh` as plain zsh and are sourced from their store path. Keeping them out of nix strings avoids escaping every `${…}` as `''${…}`; the tradeoff is that editing them needs a rebuild, unlike the out-of-store symlinks in `dotfiles.nix`.

`~/.p10k.zsh` is still a symlink into the repo, so `p10k configure` writes straight through to `apps/p10k/.p10k.zsh`.

One home-manager default is deliberately overridden: `history.share` is `true` upstream, but the old `.zshrc` never set `SHARE_HISTORY` and it conflicts with `INC_APPEND_HISTORY_TIME`, so `zsh.nix` pins it to `false`.

AeroSpace is fully declarative: `hosts/darwin/aerospace.nix` generates its TOML into the store and nix-darwin runs it under launchd, so there is no `~/.aerospace.toml`. `start-at-login` is deliberately unset — the module asserts on it, because the launchd agent is what starts AeroSpace.

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

1. Add the file under `apps/<app>/`, e.g. `apps/newapp/config.toml`.
2. Add an entry to `home/dotfiles.nix` (paths are relative to `apps/`):

```nix
xdg.configFile."newapp/config.toml".source = link "newapp/config.toml";
# or, for a dotfile directly in $HOME:
home.file.".newapprc".source = link "newapp/.newapprc";
```

If the app also needs a nix module, put it beside its config as `apps/newapp/newapp.nix` and import it from `apps/config.nix`.

3. `sudo darwin-rebuild switch --flake .#mba`

These are out-of-store symlinks (`mkOutOfStoreSymlink`), so edits to the file in this repo take effect immediately without a rebuild.

## Adding a Package

Prefer nixpkgs; use Homebrew for GUI apps and anything not packaged for nix.

```nix
# home/packages.nix — CLI tools
home.packages = with pkgs; [ ripgrep jq gh ];

# hosts/darwin/homebrew.nix — GUI apps + brew-only formulae
casks = [ "ghostty" ];
brews = [ "mas" ];
```

Then `sudo darwin-rebuild switch --flake .#mba`.

## Homebrew

`homebrew.onActivation.cleanup = "zap"` means anything installed via Homebrew but *not* listed in `homebrew.nix` gets uninstalled (and its config zapped) on the next activation. The Brewfile is the source of truth — a manual `brew install foo` survives only until the next switch.

### Installing an app

Find the exact name first, since casks and formulae share a namespace:

```bash
brew search <name>
brew info --cask <name>       # confirm it's the one you want
```

Then add it to `hosts/darwin/homebrew.nix` — `casks` for GUI apps and fonts, `brews` for CLI formulae — and switch:

```bash
sudo darwin-rebuild switch --flake .#mba
```

To remove an app, delete its line and switch; cleanup zaps it, config and all.

### Updating

`onActivation.autoUpdate` and `onActivation.upgrade` are both on, so a normal switch already runs `brew update` and upgrades everything outdated. There is no separate update step:

```bash
sudo darwin-rebuild switch --flake .#mba
```

Upgrading by hand works too, but only until the next activation re-reconciles things:

```bash
brew update && brew upgrade
```

### Inspecting

`global.brewfile = true` points `HOMEBREW_BUNDLE_FILE` at the generated Brewfile in the store, so plain `brew bundle` subcommands read the declarative list rather than a hand-maintained one:

```bash
echo $HOMEBREW_BUNDLE_FILE     # the generated Brewfile
brew bundle list --all         # everything the flake declares
brew bundle check              # is the system in sync with it?
brew bundle cleanup            # what zap would remove (lists only, without --force)
brew outdated                  # what the next switch will upgrade
```

`brew bundle list` defaults to formulae only — `--all` is what shows casks and taps as well.

### Mac App Store

`mas` is installed and `masApps` in `homebrew.nix` lists the App Store apps to keep. App IDs come from:

```bash
mas search <name>
mas list                       # already-installed apps and their IDs
```

## Third-Party Tap Trust

Homebrew 6.0 enables `HOMEBREW_REQUIRE_TAP_TRUST`, refusing to load formulae or casks from non-official taps until they are explicitly trusted. Untrusted entries abort activation — including the `brew cleanup` that runs at the end of the bundle step.

There are no third-party taps in `homebrew.nix` right now — AeroSpace moved to nixpkgs and took the last one with it. Keep this in mind before adding one back.

**The Brewfile is the only durable source of trust here.** Because `onActivation.cleanup` implies `--force-cleanup`, every activation runs `Homebrew::Trust.replace!` (`bundle/subcommand/cleanup.rb`), which overwrites `~/.homebrew/trust.json` with exactly the entries the Brewfile declares. Anything added out of band — a manual `brew trust`, or a `nix-homebrew.trust` block — is wiped mid-activation, and the `brew cleanup` that runs immediately after then fails on the now-untrusted item.

Bundle only emits a trust entry for a **fully-qualified** name, so a tapped cask has to be listed as:

```nix
casks = [ "user/tap/somecask" ];
```

Fully-qualifying a `brew` has a side effect that a `cask` doesn't: `kept_formulae` compares the Brewfile name against each installed formula's `full_name`, so `brew "user/tap/foo"` will not match an installed `foo` and cleanup uninstalls it. Check with `brew bundle cleanup --file=<brewfile>` (no `--force` — it only lists) before fully-qualifying a formula.

Tap-wide trust is also possible (`taps = [ { name = "user/tap"; trusted = true; } ]`), but it covers all of that tap's current *and future* contents.
