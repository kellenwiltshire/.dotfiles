#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

echo "🐹 Installing Go..."

if command -v go >/dev/null 2>&1; then
  echo "✅ go already installed."
  go version
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  install_brew_package go
elif command -v apt >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y golang-go
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y golang
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm go
else
  echo "No supported package manager found for Go."
  exit 1
fi

go version
