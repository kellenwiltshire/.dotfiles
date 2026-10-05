#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

echo "📦 Installing shell dependencies..."

install_package zsh
install_package stow
install_package zoxide
install_package fzf
install_package tmux
install_package direnv

if [[ "$(detect_distro)" == "debian" ]]; then
  install_package git
  install_package curl
  install_package unzip
  install_package cc build-essential
  install_package batcat bat
  install_package fdfind fd-find
  install_package rg ripgrep
  install_package jq
  install_package tldr tealdeer
  install_package btop
  install_package gh

  mkdir -p "$HOME/.local/bin"
  [[ -x "$HOME/.local/bin/bat" ]] || ln -sfn "$(command -v batcat)" "$HOME/.local/bin/bat"
  [[ -x "$HOME/.local/bin/fd" ]] || ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"

  case "$(uname -m)" in
    x86_64)
      release_arch="amd64"
      gnu_arch="x86_64"
      lazygit_arch="x86_64"
      tree_sitter_arch="x64"
      nvim_arch="x86_64"
      ;;
    aarch64|arm64)
      release_arch="arm64"
      gnu_arch="aarch64"
      lazygit_arch="arm64"
      tree_sitter_arch="arm64"
      nvim_arch="arm64"
      ;;
    *)
      echo "Unsupported Debian architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac

  zoxide_version="$(zoxide --version | awk '{ print $2 }')"
  if ! version_at_least "$zoxide_version" "0.9.0"; then
    tag="$(github_latest_release_tag ajeetdsouza/zoxide)"
    version="${tag#v}"
    install_tar_binary \
      "https://github.com/ajeetdsouza/zoxide/releases/download/$tag/zoxide-$version-${gnu_arch}-unknown-linux-musl.tar.gz" \
      zoxide
  fi

  fzf_version="$(fzf --version | cut -d' ' -f1)"
  if ! version_at_least "$fzf_version" "0.53.0"; then
    tag="$(github_latest_release_tag junegunn/fzf)"
    version="${tag#v}"
    install_tar_binary \
      "https://github.com/junegunn/fzf/releases/download/$tag/fzf-$version-linux_$release_arch.tar.gz" \
      fzf
  fi

  if ! command -v eza >/dev/null 2>&1; then
    if apt_has_package eza; then
      install_package eza
    else
      install_tar_binary \
        "https://github.com/eza-community/eza/releases/latest/download/eza_${gnu_arch}-unknown-linux-gnu.tar.gz" \
        eza
    fi
  fi

  if ! command -v delta >/dev/null 2>&1; then
    if apt_has_package git-delta; then
      install_package delta git-delta
    else
      tag="$(github_latest_release_tag dandavison/delta)"
      version="${tag#v}"
      install_tar_binary \
        "https://github.com/dandavison/delta/releases/download/$tag/delta-$version-${gnu_arch}-unknown-linux-gnu.tar.gz" \
        delta
    fi
  fi

  if ! command -v lazygit >/dev/null 2>&1; then
    if apt_has_package lazygit; then
      install_package lazygit
    else
      tag="$(github_latest_release_tag jesseduffield/lazygit)"
      version="${tag#v}"
      install_tar_binary \
        "https://github.com/jesseduffield/lazygit/releases/download/$tag/lazygit_${version}_Linux_${lazygit_arch}.tar.gz" \
        lazygit
    fi
  fi

  tree_sitter_version=""
  if command -v tree-sitter >/dev/null 2>&1; then
    tree_sitter_version="$(tree-sitter --version | awk '{ print $2 }')"
  fi
  if [[ -z "$tree_sitter_version" ]] || ! version_at_least "$tree_sitter_version" "0.25.0"; then
    tree_sitter_download="$(mktemp)"
    curl -fsSL \
      "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-$tree_sitter_arch.gz" |
      gzip -dc > "$tree_sitter_download"
    install -m 755 "$tree_sitter_download" "$HOME/.local/bin/tree-sitter"
    rm -f "$tree_sitter_download"
  fi

  nvim_version=""
  if command -v nvim >/dev/null 2>&1; then
    nvim_version="$(nvim --version | awk 'NR == 1 { sub(/^NVIM v/, ""); print; exit }')"
  fi
  if [[ -z "$nvim_version" ]] || ! version_at_least "$nvim_version" "0.11.0"; then
    nvim_archive="$(mktemp)"
    nvim_extract="$(mktemp -d)"
    curl -fsSL \
      "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$nvim_arch.tar.gz" \
      -o "$nvim_archive"
    tar -xzf "$nvim_archive" -C "$nvim_extract"
    rm -rf "$HOME/.local/opt/nvim"
    mkdir -p "$HOME/.local/opt"
    mv "$nvim_extract/nvim-linux-$nvim_arch" "$HOME/.local/opt/nvim"
    ln -sfn "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"
    rm -rf "$nvim_archive" "$nvim_extract"
  fi

  if ! command -v carapace >/dev/null 2>&1; then
    tag="$(github_latest_release_tag carapace-sh/carapace-bin)"
    version="${tag#v}"
    install_tar_binary \
      "https://github.com/carapace-sh/carapace-bin/releases/download/$tag/carapace-bin_${version}_linux_${release_arch}.tar.gz" \
      carapace
  fi

  if ! command -v oh-my-posh >/dev/null 2>&1; then
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
  fi
elif [[ "$(detect_os)" == "linux" ]]; then
  echo "📦 Installing modern CLI tools..."
  install_package bat
  install_package fd
  install_package eza
  install_package delta git-delta
  install_package lazygit
  install_package rg ripgrep
  install_package jq
  install_package tldr tealdeer
  install_package btop
  install_package nvim neovim
  # nvim-treesitter's main branch shells out to the tree-sitter CLI to build parsers.
  install_package tree-sitter tree-sitter-cli
fi
