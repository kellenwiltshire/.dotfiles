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

repo_name=$(basename "$repo_root")

# stow --restow only knows about files the package still contains, so deleting or
# renaming one leaves a dangling symlink in $HOME forever. Clear those out first.
prune_orphans() {
  local package="$1"
  local entry target link dest

  while IFS= read -r entry; do
    target="$HOME/$(basename "$entry")"
    [[ -e "$target" || -L "$target" ]] || continue

    while IFS= read -r link; do
      dest=$(readlink "$link")

      case "$dest" in
        "$repo_root"/* | *"/$repo_name/$package/"*) ;;
        *) continue ;;
      esac

      [[ -e "$link" ]] && continue

      echo "🧹 Removing orphaned symlink $link"
      rm -f "$link"
    done < <(find "$target" -type l 2>/dev/null)
  done < <(find "$package" -mindepth 1 -maxdepth 1)
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
  prune_orphans "$package"
  backup_conflicts "$package"
  stow --no-folding --restow --verbose "$package"
done
