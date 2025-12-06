#!/bin/bash

set -e

# Function from 'detect os and package manager' script
# shellcheck disable=SC1091
source "$(dirname "$0")/detect_os_and_package_manager.sh"
detect_os_and_manager

# shellcheck disable=SC2153
echo "-----> Configuration pour : $DETECTED_OS avec $DETECTED_PM"

# Plugins installation logic when package manager is needed
if [ "$DETECTED_OS" == "macOS" ]; then

    # MacOS case :
    brew install autojump fzf


    # Linux case : Use the good package manager
elif [ "$DETECTED_OS" == "Linux" ]; then
    echo "-----> Installation de 'Zsh' et 'Curl' via $DETECTED_PM..."

    case $DETECTED_PM in
        apt)
            sudo apt update && sudo apt install -y autojump fzf
            ;;
        dnf)
            sudo dnf install -y autojump-zsh fzf
            ;;
        *)
            echo "❌ Gestionnaire de paquets non supporté pour l'installation auto."
            exit 1
            ;;
    esac
fi

# setting the var if needed
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# 'zsh-autosuggestions' plugin installation by cloning its git repo
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# 'fast-syntax-highlighting' plugin installation by cloning its git repo
if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
fi

# 'you-should-use' plugin installation by cloning its git repo
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-you-should-use" ]; then
  git clone https://github.com/MichaelAquilina/zsh-you-should-use.git \
    "$ZSH_CUSTOM/plugins/you-should-use"
fi
