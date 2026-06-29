#!/bin/bash

set -euo pipefail

echo "📦 Installing nvm..."

mkdir -p "$HOME/.nvm"

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  echo "✅ nvm already installed."
else
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

source "$HOME/.nvm/nvm.sh"

echo "📦 Installing Node LTS..."

nvm install --lts
nvm alias default lts/*
nvm use default
