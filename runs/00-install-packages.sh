#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/../scripts/lib.sh"

echo "📦 Installing shell dependencies..."

install_package zsh
install_package stow
install_package zoxide
# tmux-sessionizer (prefix+f) and the fzf-tab plugin both hard-depend on fzf, so it cannot wait
# for the macOS Brewfile: one failed entry there aborts the whole bundle and leaves fzf missing.
install_package fzf

# On macOS these come from the Brewfile; install them here for Linux parity so the
# shared zsh/git config never references a missing binary (bat, fd, eza, delta, …).
if [[ "$(detect_os)" == "linux" ]]; then
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
