#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

echo "📦 Installing shell dependencies..."

install_package zsh
install_package stow
install_package zoxide
