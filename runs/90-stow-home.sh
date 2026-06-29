#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
package="home"

echo "🔗 Stowing $package dotfiles..."

cd "$repo_root"

resolve_link() {
  local path="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$path" 2>/dev/null || true
  else
    readlink "$path" 2>/dev/null || true
  fi
}

while IFS= read -r src; do
  rel="${src#"$package"/}"
  target="$HOME/$rel"
  src_abs="$repo_root/$src"

  if [[ -L "$target" && "$(resolve_link "$target")" == "$src_abs" ]]; then
    continue
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    backup="$target.backup"
    if [[ -e "$backup" || -L "$backup" ]]; then
      backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    fi
    echo "📦 Backing up $target -> $backup"
    mv "$target" "$backup"
  fi
done < <(find "$package" -type f)

stow --restow --verbose "$package"
