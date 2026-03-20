export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="afowler"

zstyle ':omz:update' mode auto

plugins=(git)

source $ZSH/oh-my-zsh.sh

eval "$(/opt/homebrew/bin/brew shellenv)"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=$(brew --prefix)/share/zsh-syntax-highlighting/highlighters

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
[ -f "${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/golang/set-env.zsh" ] && . "${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/golang/set-env.zsh"

HISTFILESIZE=100000
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY_TIME
setopt HIST_VERIFY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

bindkey '^U' backward-kill-line

compdef dotfiles=git

alias l="ls -AF"
alias ll="ls -lh"
alias la="ls -A"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias c="claude"

alias router_ip="route -n get default -ifscope en0 | awk '/gateway/ { print \$2 }'"

alias docker-killall="docker ps | tail -n +2 | cut -f1 -d' ' | xargs docker kill"
alias docker-cleanup="docker ps -a | cut -f1 -d' ' | tail -n +2 | xargs docker rm"
alias docker-exec-latest="docker exec -ti \$(docker ps --latest --quiet) bash"

alias flush-dns-cache="sudo killall -HUP mDNSResponder"

alias tf="terraform"

alias fast='networkQuality -v'

alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias tfdocs='terraform-docs markdown table --output-file README.md --output-mode inject .'
alias tflock='terraform providers lock -platform=darwin_arm64 -platform=linux_amd64 -platform=darwin_amd64'

# Complete ssh with hosts in ~/.ssh/config
zstyle -s ':completion:*:hosts' hosts _ssh_config
if [[ -r ~/.ssh/config ]]; then
  _ssh_config+=($(cat ~/.ssh/config | grep -v '\*' | sed -ne 's/Host[=\t ]//p'))
fi
zstyle ':completion:*:hosts' hosts $_ssh_config

ginit() {
  git init "$@"
  cp ~/.git-templates/.gitignore "${1:-.}/.gitignore"
  cp ~/.git-templates/.tool-versions "${1:-.}/.tool-versions"
}

batt() {
  time_remaining=$(pmset -g batt | grep -Eo "([0-9]+:[0-9]+)")
  pct_remaining=$(pmset -g batt | grep -Eo "([0-9]+\%)")
  echo "$time_remaining remaining ($pct_remaining)"
}

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
