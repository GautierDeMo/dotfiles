#!/bin/bash

# Clones a Git repository into a destination directory.
# Checks if the directory already exists before cloning.
#
# @param $1 The URL of the Git repository to clone.
# @param $2 The name/identifier of the repository (for logging).
# @param $3 The destination path where the repository should be cloned.
clone_repo() {
  local repo=$1
  local name=$2
  local dir=$3

  if [ ! -d "$dir" ]; then
    echo "📥 Installing $name..."
    if git clone "$repo" "$dir"; then
      echo "✅ $name installed."
      echo ""
    else
      echo "❌ Error while installing $name."
      echo ""
      return 1
    fi
  else
    echo "✅ $name already installed."
    echo ""
  fi
}

# Clones a Zsh plugin from a given Git repository.
# Checks if the plugin directory already exists before cloning.
#
# @param $1 The URL of the Git repository to clone.
# @param $2 The name of the plugin (used as directory name).
clone_plugin() {
  local repo=$1
  local name=$2
  local dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"

  clone_repo "$repo" "$name" "$dir"
}

# Clones a Zsh theme from a given Git repository.
# Checks if the theme directory already exists before cloning.
#
# @param $1 The URL of the Git repository to clone.
# @param $2 The name of the theme (used as directory name).
clone_theme() {
  local repo=$1
  local name=$2
  local dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/$name"

  clone_repo "$repo" "$name" "$dir"
}
