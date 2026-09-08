#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)

conf="$repo_root/shared/.config/tmux/tmux.conf"

# The rounded caps on the current window tab are U+E0B6 and U+E0B4. Private Use Area codepoints
# like those get dropped silently by some editors and coding agents on write, which is exactly how
# this file lost them once: tmux went on rendering plain blocks and nothing anywhere reported an
# error. Since putting them back is a two-line substitution, do that rather than only complain.

left=$(printf '\xee\x82\xb6')
right=$(printf '\xee\x82\xb4')

has_glyphs() {
  LC_ALL=C grep -qF "$left" "$conf" && LC_ALL=C grep -qF "$right" "$conf"
}

if has_glyphs; then
  echo "✅ tmux separator glyphs intact."
  exit 0
fi

echo "🔧 tmux separator glyphs are missing — restoring them..."
perl -i -pe '
  s/\Q"#[fg=#82aaff]#[bg=#82aaff\E/"#[fg=#82aaff]\xee\x82\xb6#[bg=#82aaff/;
  s/\Q#[bg=default,fg=#82aaff]"\E/#[bg=default,fg=#82aaff]\xee\x82\xb4"/;
' "$conf"

if ! has_glyphs; then
  echo "❌ Could not restore them: window-status-current-format no longer matches the pattern" >&2
  echo "   this script substitutes into. Re-add U+E0B6 after the opening #[fg=...] and U+E0B4" >&2
  echo "   at the end of the format by hand, with printf rather than an editor." >&2
  exit 1
fi

echo "✅ Restored. Reload with: tmux source-file ~/.config/tmux/tmux.conf"
