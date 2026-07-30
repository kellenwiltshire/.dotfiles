#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

pubkey="$HOME/.ssh/id_ed25519.pub"
signers="$HOME/.ssh/allowed_signers"

if [[ ! -f "$pubkey" ]]; then
  echo "⚠️  No $pubkey. Commit signing is enabled, so commits will fail until you run:"
  echo "      ssh-keygen -t ed25519"
  echo "    then: ./setup.sh ssh-allowed-signers"
  exit 0
fi

# --includes is off by default for --global, and the identity may live in the
# shared include rather than ~/.gitconfig itself.
email="$(git config --global --includes --get user.email || true)"

if [[ -z "$email" ]]; then
  echo "⏭️  No git user.email configured; skipping allowed_signers."
  exit 0
fi

entry="$email $(cut -d' ' -f1,2 < "$pubkey")"

if [[ -f "$signers" && "$(cat "$signers")" == "$entry" ]]; then
  echo "✅ ~/.ssh/allowed_signers already up to date."
  exit 0
fi

echo "$entry" > "$signers"
chmod 644 "$signers"
echo "🔏 Wrote ~/.ssh/allowed_signers for: $email"
