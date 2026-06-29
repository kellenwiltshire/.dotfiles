#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

echo "🐳 Installing Docker tooling..."

if command -v brew >/dev/null 2>&1; then
  install_brew_package docker
  install_brew_package docker-buildx
  install_brew_package docker-compose
elif command -v apt >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y docker.io docker-buildx docker-compose-v2
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y docker docker-buildx-plugin docker-compose-plugin
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm docker docker-buildx docker-compose
else
  echo "No supported package manager found for Docker tooling."
  exit 1
fi

if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable --now docker
fi

docker --version
