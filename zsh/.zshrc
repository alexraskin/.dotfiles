if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

# Set powerlevel10k theme.
# https://github.com/romkatv/powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
zstyle ':omz:update' mode disabled
plugins=(git mise)
source $ZSH/oh-my-zsh.sh

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_ENV_HINTS=1

# mise
eval "$(mise activate zsh)"

# zsh plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=$(brew --prefix)/share/zsh-syntax-highlighting/highlighters

# 1pass keys
export ANTHROPIC_API_KEY=$(op read "op://Private/ata-api-key/credential" 2>/dev/null)
export GITHUB_TOKEN=$(op read "op://Private/GitHub/github-token" 2>/dev/null)

# history
HISTFILESIZE=100000
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY_TIME
setopt HIST_VERIFY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# keybindings
bindkey '^U' backward-kill-line

# go
export PATH="$HOME/go/bin:$PATH"

# claude
alias c="claude"

# git
alias g="git"
alias gst="git status"
alias gpb="git push -u origin \$(git branch --show-current)"

# ls aliases
alias l="ls -AF"
alias ll="ls -lh"
alias la="ls -A"

# directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# docker
alias docker-killall="docker ps | tail -n +2 | cut -f1 -d' ' | xargs docker kill"
alias docker-cleanup="docker ps -a | cut -f1 -d' ' | tail -n +2 | xargs docker rm"
alias docker-exec-latest="docker exec -ti \$(docker ps --latest --quiet) bash"

# network aliases
alias router_ip="route -n get default -ifscope en0 | awk '/gateway/ { print \$2 }'"
alias flush-dns-cache="sudo killall -HUP mDNSResponder"
alias fast='networkQuality -v'

# tailscale
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# terraform
alias tf="terraform"
alias tfdocs='terraform-docs markdown table --output-file README.md --output-mode inject .'
alias tflock='terraform providers lock -platform=darwin_arm64 -platform=linux_amd64 -platform=darwin_amd64'

# custom scripts
alias rip="$HOME/.dotfiles/bin/rip-with-ffmpeg.sh $@"
alias rip-yt="$HOME/.dotfiles/bin/rip-yt.sh $@"
alias fwd='~/.dotfiles/bin/forward.sh'

# used to vscode lol
alias code="zed"

# Complete ssh with hosts in ~/.ssh/config
zstyle -s ':completion:*:hosts' hosts _ssh_config
if [[ -r ~/.ssh/config ]]; then
  _ssh_config+=($(cat ~/.ssh/config | grep -v '\*' | sed -ne 's/Host[=\t ]//p'))
fi
zstyle ':completion:*:hosts' hosts $_ssh_config

# battery time remaining
batt() {
  time_remaining=$(pmset -g batt | grep -Eo "([0-9]+:[0-9]+)")
  pct_remaining=$(pmset -g batt | grep -Eo "([0-9]+\%)")
  echo "$time_remaining remaining ($pct_remaining)"
}

# Backup a file or directory to ~/backups with a timestamped filename
backup() {
  if [ -z "$1" ]; then
    echo "usage: backup FILE"
    return
  fi

  local backup_dir="$HOME/backups"
  if [ ! -d "$backup_dir" ]; then
    echo "backup directory $backup_dir does not exist"
    return
  fi

  if [ ! -e "$1" ]; then
    echo "no file or directory found at path '$1'"
    return
  fi

  local src_path=$(realpath "$1")
  local timestamp=$(date "+%Y-%m-%d--%H-%M-%S")
  local dst_path="$backup_dir/$timestamp$src_path"
  local dst_dir=$(dirname "$dst_path")

  echo "Creating backup"
  echo "  source      = $src_path"
  echo "  destination = $dst_path"
  [ ! -d "$dst_dir" ] && mkdir -p "$dst_dir"
  cp -r "$src_path" "$dst_path"
}

# keep the mac awake ;)
awake() {
  if [[ "$1" == "-t" && -n "$2" ]]; then
    echo "☕ Caffeinated for $2 seconds"
    caffeinate -u -d -t "$2"
  else
    echo "☕ Caffeinated indefinitely (Ctrl+C to stop)"
    caffeinate -u -d -i
  fi
}

gh-open() {
  local file="$1"
  if git rev-parse --git-dir > /dev/null 2>&1; then
    repo=$(git remote get-url origin|sed "s/:/\\//; s/\\.git//; s/git@/https:\\/\\//; s/https\\/\\//https:\\//")
    if [ -z "$file" ]; then
      open "${repo}"
    else
      local branch=$(git rev-parse --abbrev-ref HEAD)
      open "${repo}/blob/${branch}/${file}"
    fi
  else
    echo "not in a git repo"
  fi
}

gh-pr() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    local repo=$(git remote get-url origin|sed "s/:/\\//; s/\\.git//; s/git@/https:\\/\\//")
    local branch=$(git rev-parse --abbrev-ref HEAD)
    open "${repo}/compare/${branch}?expand=1"
  else
    echo "not in a git repo"
  fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
