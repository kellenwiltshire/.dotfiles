#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
source "$script_dir/../scripts/lib.sh"

packages=(shared)
if [[ "$(detect_os)" == "macos" ]]; then
  packages+=(macos)
else
  packages+=(linux)
fi

cd "$repo_root"

resolve_link() {
  local path="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$path" 2>/dev/null || true
  else
    readlink "$path" 2>/dev/null || true
  fi
}

backup_conflicts() {
  local package="$1"
  while IFS= read -r src; do
    local rel="${src#"$package"/}"
    local target="$HOME/$rel"
    local src_abs="$repo_root/$src"

    if [[ -L "$target" && "$(resolve_link "$target")" == "$src_abs" ]]; then
      continue
    fi

    if [[ -e "$target" || -L "$target" ]]; then
      local backup="$target.backup"
      if [[ -e "$backup" || -L "$backup" ]]; then
        backup="$target.backup.$(date +%Y%m%d%H%M%S)"
      fi
      echo "📦 Backing up $target -> $backup"
      mkdir -p "$(dirname "$backup")"
      mv "$target" "$backup"
    fi
  done < <(find "$package" -type f)
}

for package in "${packages[@]}"; do
  echo "🔗 Stowing $package dotfiles..."
  backup_conflicts "$package"
  stow --no-folding --restow --verbose "$package"
done
