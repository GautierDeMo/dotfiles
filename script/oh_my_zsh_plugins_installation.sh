#!/bin/bash
set -e

# Import common functions
# shellcheck disable=SC1091
source "$(dirname "$0")/common.sh"
# shellcheck disable=SC1091
source "$(dirname "$0")/detect_os_and_package_manager.sh"
detect_os_and_manager

echo "🔧 Setup for: $DETECTED_OS with $DETECTED_PM"
echo "======================================================================"
echo ""

# ===================================================================
# System dependencies installation
# ===================================================================

if [ "$DETECTED_OS" == "macOS" ]; then
    echo "🍎 Checking autojump and fzf via Homebrew..."
    echo ""

    # Autojump
    if ! brew list autojump &> /dev/null; then
        echo "📦 Installing autojump..."
        brew install autojump
        echo "✅ autojump installed."
        echo ""
    else
        echo "✅ autojump already installed."
        echo ""
    fi

    # FZF
    if ! brew list fzf &> /dev/null; then
        echo "🔍 Installing fzf..."
        brew install fzf
        echo "✅ fzf installed."
        echo ""
    else
        echo "✅ fzf already installed."
        echo ""
    fi

elif [ "$DETECTED_OS" == "Linux" ]; then
    echo "🐧 Installing autojump and fzf via $DETECTED_PM..."
    echo ""

    case $DETECTED_PM in
        apt)
            sudo apt update && sudo apt install -y autojump fzf
            echo ""
            echo "✅ autojump and fzf installed."
            echo ""
            ;;
        dnf)
            sudo dnf install -y autojump-zsh fzf
            echo ""
            echo "✅ autojump and fzf installed."
            echo ""
            ;;
        *)
            echo "❌ Package manager not supported for auto-install."
            echo ""
            exit 1
            ;;
    esac
fi

# ===================================================================
# Oh My Zsh environment verification
# ===================================================================

echo "----------------------------------------------------------------------"
echo "🔍 Checking Oh My Zsh environment"
echo "----------------------------------------------------------------------"
echo ""

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
if [ ! -d "$ZSH_CUSTOM" ]; then
  echo "❌ Oh My Zsh is not installed ($ZSH_CUSTOM not found)."
  echo "   Install Oh My Zsh before running this script."
  echo ""
  exit 1
fi

echo "📁 Plugins directory: $ZSH_CUSTOM/plugins"
echo ""

# ===================================================================
# Oh My Zsh plugins installation
# ===================================================================

echo "======================================================================"
echo "🧩 Installing custom Oh My Zsh plugins"
echo "======================================================================"
echo ""

# zsh-autosuggestions plugin
clone_plugin \
  "https://github.com/zsh-users/zsh-autosuggestions" \
  "zsh-autosuggestions"

# fast-syntax-highlighting plugin
clone_plugin \
  "https://github.com/zdharma-continuum/fast-syntax-highlighting" \
  "fast-syntax-highlighting"

# you-should-use plugin
clone_plugin \
  "https://github.com/MichaelAquilina/zsh-you-should-use" \
  "you-should-use"

echo "======================================================================"
echo "🎉 Plugins installation complete!"
echo "======================================================================"
echo ""
