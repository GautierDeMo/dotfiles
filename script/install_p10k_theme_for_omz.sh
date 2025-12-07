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
# Constants
# ===================================================================

P10K_README_FONTS='https://github.com/romkatv/powerlevel10k#fonts'
P10K_README_THEME='https://github.com/romkatv/powerlevel10k#oh-my-zsh'
P10K_README_CONFIG='https://github.com/romkatv/powerlevel10k#configuration'

# ===================================================================
# Meslo Nerd Font installation
# ===================================================================

echo "======================================================================"
echo "🔤 Installing fonts for Powerlevel10k"
echo "======================================================================"
echo ""

if [ "$DETECTED_OS" == "macOS" ]; then
    echo "🍎 Checking MesloLGS NF font via Homebrew..."
    echo ""

    if ! brew list font-meslo-lg-nerd-font &> /dev/null; then
        echo "📦 Installing font..."
        brew install font-meslo-lg-nerd-font
        echo "✅ Font installed."
        echo ""
    else
        echo "✅ Font already installed."
        echo ""
    fi

    echo "⚠️  Change the font in your terminal and IDE:"
    echo "📖 Guide: $P10K_README_FONTS"
    echo ""

elif [ "$DETECTED_OS" == "Linux" ]; then
    echo "🐧 Installing MesloLGS NF font..."
    echo ""

    FONT_DIR="$HOME/.local/share/fonts"
    TMP_DIR=$(mktemp -d)
    ARCHIVE="$TMP_DIR/Meslo.tar.xz"

    echo "📥 Downloading Meslo Nerd Font..."
    curl -fL --proto '=https' --tlsv1.2 \
      -o "$ARCHIVE" \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz"
    echo "✅ Archive downloaded."
    echo ""

    echo "📦 Extracting MesloLGS NF fonts..."
    mkdir -p "$FONT_DIR"
    tar -xJf "$ARCHIVE" -C "$TMP_DIR"

    # Copy only MesloLGS NF fonts
    find "$TMP_DIR" -name "MesloLGSNerdFont-*.ttf" -exec cp {} "$FONT_DIR/" \;
    echo "✅ Fonts copied to $FONT_DIR"
    echo ""

    echo "🔄 Updating font cache..."
    fc-cache -fv
    echo "✅ Font cache updated."
    echo ""

    # Verification
    if fc-list | grep -qi "MesloLGS"; then
        echo "✅ MesloLGS NF font correctly installed."
    else
        echo "⚠️  Font installed but not detected. Restart your terminal."
    fi
    echo ""

    # Cleanup
    rm -rf "$TMP_DIR"
    echo "🗑️  Temporary directory cleaned."
    echo ""

    echo "⚠️  Change the font in your terminal and IDE:"
    echo "📖 Guide: $P10K_README_FONTS"
    echo ""
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

echo "📁 Themes directory: $ZSH_CUSTOM/themes"
echo ""

# ===================================================================
# Powerlevel10k theme installation
# ===================================================================

echo "======================================================================"
echo "🎨 Installing Powerlevel10k theme"
echo "======================================================================"
echo ""

clone_theme \
  "https://github.com/romkatv/powerlevel10k.git" \
  "powerlevel10k"

echo "======================================================================"
echo "🎉 Powerlevel10k theme installed!"
echo "======================================================================"
echo ""
echo "📝 Next steps:"
echo "  1. Change the theme in your ~/.zshrc:"
echo "     ZSH_THEME=\"powerlevel10k/powerlevel10k\""
echo "  2. Restart your terminal: exec zsh"
echo "  3. Follow the Powerlevel10k configuration wizard"
echo ""
echo "📖 Guides:"
echo "   Theme: $P10K_README_THEME"
echo "   Config: $P10K_README_CONFIG"
echo ""
