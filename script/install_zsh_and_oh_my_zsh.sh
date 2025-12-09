#!/bin/bash
set -e

# Import detection function
# shellcheck disable=SC1091
source "$(dirname "$0")/detect_os_and_package_manager.sh"
detect_os_and_manager

# shellcheck disable=SC2153
echo "🔧 Setup for: $DETECTED_OS with $DETECTED_PM"
echo "======================================================================"
echo ""

# ===================================================================
# Zsh installation
# ===================================================================
if [ "$DETECTED_OS" == "macOS" ]; then
    echo "🍎 Checking Homebrew..."
    echo ""

    # macOS case: check Homebrew first
    if ! command -v brew &> /dev/null; then
        echo "📦 Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add brew to PATH temporarily
        eval "$(/opt/homebrew/bin/brew shellenv)"
        DETECTED_PM="brew"
        echo "✅ Homebrew installed and added to PATH."
        echo ""
    else
        echo "✅ Homebrew already installed."
        echo ""
    fi

    echo "🌀 Checking Zsh..."
    if ! command -v zsh &> /dev/null; then
        echo "📦 Zsh not found. Installing via Homebrew..."
        brew install zsh
        echo "✅ Zsh installed."
        echo ""
    else
        echo "✅ Zsh already installed."
        echo ""
    fi

elif [ "$DETECTED_OS" == "Linux" ]; then
    # Linux case: use detected package manager
    echo "🐧 Installing Zsh and Curl via $DETECTED_PM..."
    echo ""

    case $DETECTED_PM in
        apt)
            sudo apt update && sudo apt install -y zsh curl
            ;;
        dnf)
            sudo dnf install -y zsh curl
            ;;
        *)
            echo "❌ Package manager not supported for auto-install."
            echo ""
            exit 1
            ;;
    esac
    echo "✅ Zsh and Curl installed."
    echo ""
fi

# ===================================================================
# Oh My Zsh installation
# ===================================================================

echo "🌟 Checking Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📥 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ Oh My Zsh installed."
    echo ""
else
    echo "✅ Oh My Zsh already installed."
    echo ""
fi

# ===================================================================
# Default shell configuration
# ===================================================================

echo "🛠  Checking default shell..."
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "🔁 Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
    echo "✅ Default shell changed to Zsh."
    echo ""
else
    echo "✅ Zsh is already the default shell."
    echo ""
fi

# ===================================================================
# PATH configuration for Homebrew (macOS only)
# ===================================================================

if [ "$DETECTED_OS" == "macOS" ]; then
    echo "🔗 Checking PATH for Homebrew..."
    if ! echo "$PATH" | grep -q "/opt/homebrew/bin"; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "✅ Homebrew added to PATH."
        echo ""
    else
        echo "✅ Homebrew already in PATH."
        echo ""
    fi
fi

echo "======================================================================"
echo "🎉 Installation complete! Zsh and Oh My Zsh are ready."
echo "======================================================================"
echo ""
