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
export PATH="$HOME/.local/bin:$PATH"

detect_distro() {
  if [[ -n "${DOTFILES_DISTRO:-}" ]]; then
    echo "$DOTFILES_DISTRO"
    return
  fi

  if [[ "$(detect_os)" == "linux" && -r /etc/os-release ]]; then
    (. /etc/os-release && printf '%s\n' "${ID:-linux}")
    return
  fi

  echo ""
}

DOTFILES_DISTRO="$(detect_distro)"
export DOTFILES_DISTRO

run_as_root() {
  if [[ "$EUID" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

apt_index_updated=false

ensure_apt_index() {
  [[ "$apt_index_updated" == "true" ]] && return
  run_as_root apt-get update
  apt_index_updated=true
}

apt_has_package() {
  ensure_apt_index
  apt-cache show "$1" >/dev/null 2>&1
}

version_at_least() {
  printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

github_latest_release_tag() {
  local repo="$1"
  local release_url

  release_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$repo/releases/latest")"
  basename "$release_url"
}

download_executable() {
  local url="$1"
  local target="$2"
  local download

  mkdir -p "$(dirname "$target")"
  download="$(mktemp)"
  curl -fsSL "$url" -o "$download"
  install -m 755 "$download" "$target"
  rm -f "$download"
}

install_tar_binary() {
  local url="$1"
  local binary_name="$2"
  local target="${3:-$HOME/.local/bin/$binary_name}"
  local archive extract_dir binary

  archive="$(mktemp)"
  extract_dir="$(mktemp -d)"
  curl -fsSL "$url" -o "$archive"
  tar -xzf "$archive" -C "$extract_dir"
  binary="$(find "$extract_dir" -type f -name "$binary_name" -print -quit)"

  if [[ -z "$binary" ]]; then
    rm -rf "$archive" "$extract_dir"
    echo "Could not find $binary_name in $url." >&2
    return 1
  fi

  mkdir -p "$(dirname "$target")"
  install -m 755 "$binary" "$target"
  rm -rf "$archive" "$extract_dir"
}

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
  elif command -v apt-get >/dev/null 2>&1; then
    ensure_apt_index
    run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$package_name"
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
