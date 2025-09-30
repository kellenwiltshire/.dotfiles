## 🛠️ Zsh Environment Setup

First you need to install `stow` to manage your dotfiles

Remove any conflicting dotfiles contained in this repo from your `~/` directory

Clone this repo and `cd` into `.dotfiles`

### Automatic

Run the command (only works from fresh state)

```
./zsh-setup.sh
```

---

### Manual Method

### 1. Clone Plugins into Oh My Zsh Custom Directory

Make sure you have [Oh My Zsh](https://ohmyz.sh/) installed. Then clone the following plugins:

#### 🔍 Autosuggestions

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

#### 🌈 Syntax Highlighting

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

#### 🦇 `bat` Integration

```bash
git clone https://github.com/fdellwing/zsh-bat.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-bat
```

#### 🧠 "You Should Use" Plugin

```bash
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
```

#### 🔍🔄 `fzf-tab` for Better Tab Completion

```bash
git clone https://github.com/Aloxaf/fzf-tab \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
```

---

### 2. Install the Spaceship Prompt Theme

```bash
git clone https://github.com/spaceship-prompt/spaceship-prompt.git \
  "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1

ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" \
  "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
```

---

### 3. Install `zoxide` (Smarter `cd` Replacement)

Make sure `zoxide` is installed via your system package manager:

```bash
# For example, using Homebrew:
brew install zoxide
```

Then add the following to your `.zshrc`:

---

### 4. Install and Set Up `nvm` (Node Version Manager)

```bash
mkdir -p ~/.nvm

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

---

Then apply changes:

First run in the `.dotfiles` directory

```
stow .
```

Then run this command in the `~/` directory

```bash
source ~/.zshrc
```
