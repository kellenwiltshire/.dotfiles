#!/bin/bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
source "$script_dir/../scripts/lib.sh"

pkgfile="$repo_root/packages/arch-packages.txt"

if [[ "$(detect_os)" != "linux" ]]; then
  echo "⏭️  Skipping Arch packages (not Linux)."
  exit 0
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "⏭️  pacman not found; skipping Arch packages."
  exit 0
fi

if [[ ! -f "$pkgfile" ]]; then
  echo "⏭️  No $pkgfile yet — run 'pacdump' on a configured machine first."
  exit 0
fi

mapfile -t packages < <(grep -vE '^\s*(#|$)' "$pkgfile")

if [[ ${#packages[@]} -eq 0 ]]; then
  echo "✅ No extra Arch packages to install."
  exit 0
fi

echo "📦 Installing ${#packages[@]} Arch package(s) from arch-packages.txt..."

if command -v yay >/dev/null 2>&1; then
  yay -S --needed --noconfirm "${packages[@]}"
else
  sudo pacman -S --needed --noconfirm "${packages[@]}"
  echo "⚠️  Installed via pacman only — any AUR packages were skipped. Install yay to include them."
fi

echo "✅ Arch packages complete."
