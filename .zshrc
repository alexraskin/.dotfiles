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
. ${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/golang/set-env.zsh

export HISTFILESIZE=0
HISTSIZE=1000
SAVEHIST=1000
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias tfdocs='terraform-docs markdown table --output-file README.md --output-mode inject .'
alias tflock='terraform providers lock -platform=darwin_arm64 -platform=linux_amd64 -platform=darwin_amd64'

ginit() {
  git init "$@"
  cp ~/.git-templates/.gitignore "${1:-.}/.gitignore"
  cp ~/.git-templates/.tool-versions "${1:-.}/.tool-versions"
}