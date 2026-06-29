#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

filter=""
os=""

for arg in "$@"; do
  case "$arg" in
    --macos|-m) os="macos" ;;
    --linux|-l) os="linux" ;;
    *) filter="$arg" ;;
  esac
done

if [[ -z "$os" ]]; then
  case "$(uname -s)" in
    Darwin) os="macos" ;;
    *) os="linux" ;;
  esac
fi

export DOTFILES_OS="$os"

echo "$script_dir -- os=$DOTFILES_OS filter=$filter"

cd "$script_dir"

run_script() {
  local script="$1"

  if [[ -n "$filter" ]] && ! echo "$script" | grep -q "$filter"; then
    echo "filtering $script"
    return
  fi

  "$script"
}

if command -v gfind >/dev/null 2>&1; then
  while IFS= read -r script; do
    run_script "$script"
  done < <(gfind ./runs -maxdepth 1 -mindepth 1 -executable -type f | sort)
else
  for script in ./runs/*; do
    [[ -f "$script" && -x "$script" ]] || continue
    run_script "$script"
  done
fi

echo ""
echo "✅ Done!"
echo "👉 Restart your terminal or run: source ~/.zshrc"
