# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===================================================================
# Oh My Zsh Configuration
# ===================================================================
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  autojump
  command-not-found
  fast-syntax-highlighting
  git
  globalias
  last-working-dir
  nvm
  you-should-use
  zsh-autosuggestions
  zsh-interactive-cd
)

# ===================================================================
# Environment Variables
# ===================================================================

# Opt out of Homebrew's analytics
export HOMEBREW_NO_ANALYTICS=1

# Android SDK path
if [[ `uname` =~ "Darwin" ]]; then
  # macOS
  export PATH="${HOME}/Library/Android/sdk/build-tools/36.0.0:${PATH}"
else
  # Linux
  export PATH="${HOME}/Android/Sdk/build-tools/36.0.0:${PATH}"
fi

# ===================================================================
# Load Oh My Zsh
# ===================================================================
source "${ZSH}/oh-my-zsh.sh"

# ===================================================================
# SSH Agent Configuration
# ===================================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
  eval $(keychain --eval --agents ssh id_ed25519)
fi

# ===================================================================
# Load Version Managers
# ===================================================================
# rbenv
export PATH="${HOME}/.rbenv/bin:${PATH}"
type -a rbenv > /dev/null && eval "$(rbenv init -)"

# pyenv
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
type -a pyenv > /dev/null && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init - 2> /dev/null)" && RPROMPT+='[🐍 $(pyenv version-name)]'

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Auto nvm use
autoload -U add-zsh-hook
load-nvmrc() {
  if nvm -v &> /dev/null; then
    local node_version="$(nvm version)"
    local nvmrc_path="$(nvm_find_nvmrc)"

    if [ -n "$nvmrc_path" ]; then
      local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

      if [ "$nvmrc_node_version" = "N/A" ]; then
        nvm install
      elif [ "$nvmrc_node_version" != "$node_version" ]; then
        nvm use --silent
      fi
    elif [ "$node_version" != "$(nvm version default)" ]; then
      nvm use default --silent
    fi
  fi
}
type -a nvm > /dev/null && add-zsh-hook chpwd load-nvmrc
type -a nvm > /dev/null && load-nvmrc

# ===================================================================
# PATH Additions
# ===================================================================
# Rails and Ruby uses the local `bin` folder to store binstubs.
# So instead of running `bin/rails` like the doc says, just run `rails`
# Same for `./node_modules/.bin` and nodejs
export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin"

# ===================================================================
# Aliases
# ===================================================================
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# ===================================================================
# Locale and Editors
# ===================================================================
# Encoding stuff for the terminal
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export BUNDLER_EDITOR=code
export EDITOR=code

# Set ipdb as the default Python debugger
export PYTHONBREAKPOINT=ipdb.set_trace

# ===================================================================
# Tool Integrations
# ===================================================================
# autojump
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Docker CLI completions
fpath=(/Users/gautierdemauroy/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# iTerm2 integration
test -e /Users/gautierdemauroy/.iterm2_shell_integration.zsh && source /Users/gautierdemauroy/.iterm2_shell_integration.zsh || true

# Enable Docker BuildKit
export COMPOSE_BAKE=true

# Custom aliases

# bun completions
[ -s "/Users/gautierdemauroy/.bun/_bun" ] && source "/Users/gautierdemauroy/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
