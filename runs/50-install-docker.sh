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
  install_package curl
  install_package docker docker.io

  if ! docker buildx version >/dev/null 2>&1; then
    if apt_has_package docker-buildx; then
      ensure_apt_index
      run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y docker-buildx
    else
      case "$(uname -m)" in
        x86_64) docker_arch="amd64" ;;
        aarch64|arm64) docker_arch="arm64" ;;
        *)
          echo "Unsupported Docker plugin architecture: $(uname -m)" >&2
          exit 1
          ;;
      esac
      tag="$(github_latest_release_tag docker/buildx)"
      download_executable \
        "https://github.com/docker/buildx/releases/download/$tag/buildx-$tag.linux-$docker_arch" \
        "$HOME/.docker/cli-plugins/docker-buildx"
    fi
  fi

  if ! docker compose version >/dev/null 2>&1; then
    if apt_has_package docker-compose-v2; then
      ensure_apt_index
      run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y docker-compose-v2
    fi
  fi

  if ! docker compose version >/dev/null 2>&1; then
    case "$(uname -m)" in
      x86_64) compose_arch="x86_64" ;;
      aarch64|arm64) compose_arch="aarch64" ;;
      *)
        echo "Unsupported Docker Compose architecture: $(uname -m)" >&2
        exit 1
        ;;
    esac
    download_executable \
      "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$compose_arch" \
      "$HOME/.docker/cli-plugins/docker-compose"
  fi
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y docker docker-buildx-plugin docker-compose-plugin
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm docker docker-buildx docker-compose
else
  echo "No supported package manager found for Docker tooling."
  exit 1
fi

if command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
  run_as_root systemctl enable --now docker
fi

if [[ "$(detect_os)" == "linux" && "$EUID" -ne 0 ]] &&
  ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
  run_as_root usermod -aG docker "$USER"
  echo "ℹ️  Added $USER to the docker group; log out and back in before using Docker."
fi

docker --version
docker buildx version
docker compose version
