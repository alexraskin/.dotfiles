# Shell functions, kept as plain zsh so they need no nix string escaping.
# Sourced from apps/zsh/zsh.nix via its store path.

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
    repo=$(git remote get-url origin|sed "s/:/\//; s/\.git//; s/git@/https:\/\//; s/https\/\//https:\//")
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
    local repo=$(git remote get-url origin|sed "s/:/\//; s/\.git//; s/git@/https:\/\//")
    local branch=$(git rev-parse --abbrev-ref HEAD)
    open "${repo}/compare/${branch}?expand=1"
  else
    echo "not in a git repo"
  fi
}
