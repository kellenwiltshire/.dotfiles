#!/bin/bash

set -e

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "🔧 Installing Zsh plugins..."

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# zsh-bat
git clone https://github.com/fdellwing/zsh-bat.git "$ZSH_CUSTOM/plugins/zsh-bat"

# you-should-use
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"

# fzf-tab
git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"

echo "✨ Installing Spaceship prompt theme..."
git clone https://github.com/spaceship-prompt/spaceship-prompt.git \
  "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1

ln -sf "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" \
  "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

echo "🚀 Installing zoxide..."

if command -v zoxide >/dev/null 2>&1; then
  echo "✅ zoxide already installed."
elif command -v apt >/dev/null 2>&1; then
  sudo apt update && sudo apt install -y zoxide
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y zoxide
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -S zoxide --noconfirm
else
  echo "⚠️ Package manager not supported. Please install zoxide manually:"
  echo "👉 https://github.com/ajeetdsouza/zoxide"
fi

echo "📦 Installing nvm..."

# Create .nvm directory if it doesn't exist
mkdir -p "$HOME/.nvm"

# Download and run the install script
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

echo ""
echo "✅ Done!"
echo "👉 Restart your terminal or run: source ~/.zshrc"
