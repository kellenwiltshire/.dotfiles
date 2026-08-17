#!/bin/bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
source "$script_dir/lib.sh"

out="$repo_root/packages/arch-packages.txt"

if [[ "$(detect_os)" != "linux" ]]; then
  echo "⏭️  pacdump only runs on Linux."
  exit 0
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "❌ pacman not found — this is only for Arch/Omarchy."
  exit 1
fi

baseline="$(mktemp)"
explicit="$(mktemp)"
trap 'rm -f "$baseline" "$explicit"' EXIT

omarchy_install="${OMARCHY_PATH:-/usr/share/omarchy}/install"
if [[ -d "$omarchy_install" ]]; then
  cat "$omarchy_install"/omarchy-base.packages "$omarchy_install"/omarchy-other.packages 2>/dev/null \
    | grep -vE '^\s*(#|$)' | sort -u > "$baseline"
else
  echo "⚠️  Omarchy manifests not found at $omarchy_install."
  echo "   Writing all explicit packages (no baseline to subtract)."
fi

# Omarchy marks its own meta packages explicit, but they aren't in the manifests,
# so they'd otherwise show up as things you added. Reinstalling them on a restore
# is wrong: they're the OS, already present before setup.sh ever runs.
cat >> "$baseline" <<'META'
omarchy
omarchy-dev
omarchy-keyring
omarchy-settings
omarchy-settings-dev
META
sort -u -o "$baseline" "$baseline"

pacman -Qqe | sort -u > "$explicit"

mkdir -p "$(dirname "$out")"
{
  echo "# Arch/Omarchy packages added on top of Omarchy's defaults."
  echo "# Regenerate: pacdump   Restore: runs/05-arch-packages.sh (run by setup.sh on Linux)."
  comm -23 "$explicit" "$baseline"
} > "$out"

count="$(comm -23 "$explicit" "$baseline" | wc -l | tr -d ' ')"
echo "✅ Wrote $count package(s) to $out"
echo "   Review with: git -C \"$repo_root\" diff packages/arch-packages.txt"
