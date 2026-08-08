{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # share is home-manager's default but not what ~/.zshrc did before, and
    # SHARE_HISTORY conflicts with INC_APPEND_HISTORY_TIME below.
    history = {
      size = 100000;
      save = 100000;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = false;
    };

    setOptions = [
      "INC_APPEND_HISTORY_TIME"
      "HIST_VERIFY"
      "HIST_REDUCE_BLANKS"
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "mise"
      ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    shellAliases = {
      c = "claude";

      nix-switch = "sudo /nix/var/nix/profiles/default/bin/nix --extra-experimental-features 'nix-command flakes' run nix-darwin/master#darwin-rebuild -- switch --flake path:/Users/alex/.dotfiles#mba";

      # Apply only the home-manager half — no sudo, no system changes. Enough
      # for anything under apps/ or home/dotfiles.nix; not for hosts/.
      hm-switch = "\"$(nix build --no-link --print-out-paths 'path:/Users/alex/.dotfiles#darwinConfigurations.mba.config.home-manager.users.alex.home.activationPackage')/activate\"";

      g = "git";
      gst = "git status";
      gpb = "git push -u origin $(git branch --show-current)";

      ff = "fastfetch";

      l = "ls -AF";
      ll = "ls -lh";
      la = "ls -A";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      docker-killall = "docker ps | tail -n +2 | cut -f1 -d' ' | xargs docker kill";
      docker-cleanup = "docker ps -a | cut -f1 -d' ' | tail -n +2 | xargs docker rm";
      docker-exec-latest = "docker exec -ti $(docker ps --latest --quiet) bash";

      router_ip = "route -n get default -ifscope en0 | awk '/gateway/ { print $2 }'";
      flush-dns-cache = "sudo killall -HUP mDNSResponder";
      fast = "networkQuality -v";

      tf = "terraform";
      tfdocs = "terraform-docs markdown table --output-file README.md --output-mode inject .";
      tflock = "terraform providers lock -platform=darwin_arm64 -platform=linux_amd64 -platform=darwin_amd64";

      rip = "$HOME/.dotfiles/bin/rip-with-ffmpeg.sh";
      rip-yt = "$HOME/.dotfiles/bin/rip-yt.sh";
      fwd = "$HOME/.dotfiles/bin/forward.sh";

      code = "zed";
    };

    initContent = lib.mkMerge [
      # Anything that may need console input has to precede the p10k instant
      # prompt, and the instant prompt has to precede everything else.
      (lib.mkOrder 500 ''
        if [[ -f ~/.zshrc.local ]]; then
          source ~/.zshrc.local
        fi

        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      ''
        # Homebrew
        eval "$(/opt/homebrew/bin/brew shellenv)"
        export HOMEBREW_NO_ENV_HINTS=1

        # 1pass keys
        export ANTHROPIC_API_KEY=$(op read "op://Private/ata-api-key/credential" 2>/dev/null)
        export GITHUB_TOKEN=$(op read "op://Private/GitHub/github-token" 2>/dev/null)

        # go
        export PATH="$HOME/go/bin:$PATH"

        # keybindings
        bindkey '^U' backward-kill-line

        # Complete ssh with hosts in ~/.ssh/config
        zstyle -s ':completion:*:hosts' hosts _ssh_config
        if [[ -r ~/.ssh/config ]]; then
          _ssh_config+=($(cat ~/.ssh/config | grep -v '\*' | sed -ne 's/Host[=\t ]//p'))
        fi
        zstyle ':completion:*:hosts' hosts $_ssh_config

        source ${./shell-functions.sh}
      ''

      (lib.mkAfter ''
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '')
    ];
  };
}
