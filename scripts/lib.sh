#!/bin/bash

detect_os() {
  if [[ -n "${DOTFILES_OS:-}" ]]; then
    echo "$DOTFILES_OS"
    return
  fi

  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    *) echo "linux" ;;
  esac
}

DOTFILES_OS="$(detect_os)"
export DOTFILES_OS

# A just-installed Homebrew is not on PATH yet, and setup.sh runs each runs/ script as its own
# process, so the shellenv eval in 00-install-homebrew.sh cannot reach the scripts after it.
# Re-apply it on every source, otherwise install_package falls through every branch and reports
# no supported package manager on a fresh Mac.
ensure_brew_on_path() {
  command -v brew >/dev/null 2>&1 && return 0

  local candidate
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$candidate" ]]; then
      eval "$("$candidate" shellenv)"
      return 0
    fi
  done

  # Best effort: finding nothing is normal on Linux, and every caller runs under set -e, so a
  # non-zero status here would abort the script at the point it sources this file.
  return 0
}

ensure_brew_on_path

install_package() {
  local command_name="$1"
  local package_name="${2:-$command_name}"

  if command -v "$command_name" >/dev/null 2>&1; then
    echo "✅ $command_name already installed."
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    brew install "$package_name"
  elif command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y "$package_name"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "$package_name"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm "$package_name"
  else
    echo "No supported package manager found for $package_name."
    return 1
  fi
}

install_brew_package() {
  local package_name="$1"

  if brew list --formula "$package_name" >/dev/null 2>&1; then
    echo "✅ $package_name already installed."
    return
  fi

  brew install "$package_name"
}

install_brew_cask() {
  local package_name="$1"

  if brew list --cask "$package_name" >/dev/null 2>&1; then
    echo "✅ $package_name already installed."
    return
  fi

  brew install --cask "$package_name"
}

clone_or_update() {
  local repo="$1"
  local target="$2"
  local depth="${3:-}"

  if [[ -d "$target/.git" ]]; then
    echo "🔄 Updating $target"
    git -C "$target" pull --ff-only
    return
  fi

  if [[ -e "$target" ]]; then
    echo "$target exists but is not a git repo."
    return 1
  fi

  mkdir -p "$(dirname "$target")"

  if [[ -n "$depth" ]]; then
    git clone "$repo" "$target" --depth="$depth"
  else
    git clone "$repo" "$target"
  fi
}
