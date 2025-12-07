#!/bin/bash
set -e

# Function from 'detect os and package manager' script
# shellcheck disable=SC1091
source "$(dirname "$0")/detect_os_and_package_manager.sh"
detect_os_and_manager

# shellcheck disable=SC2153
echo "🔧 Configuration pour : $DETECTED_OS avec $DETECTED_PM"
echo "======================================================================"
echo ""

# Zsh installation logic
if [ "$DETECTED_OS" == "macOS" ]; then
    echo "🍎 Vérification de Homebrew..."
    echo ""

    # MacOS case: Check Homebrew first
    if ! command -v brew &> /dev/null; then
        echo "📦 Homebrew non trouvé. Installation en cours..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add brew to path temporary for what's after
        eval "$(/opt/homebrew/bin/brew shellenv)"
        DETECTED_PM="brew"
        echo "✅ Homebrew installé et ajouté au PATH."
        echo ""
    else
        echo "✅ Homebrew déjà installé."
        echo ""
    fi

    echo "🌀 Installation de Zsh via Homebrew..."
    if ! command -v zsh &> /dev/null; then
        echo "📦 Zsh non trouvé. Installation..."
        brew install zsh
        echo "✅ Zsh installé."
        echo ""
    else
        echo "✅ Zsh est déjà installé."
        echo ""
    fi

    # Linux case: Use the good package manager
elif [ "$DETECTED_OS" == "Linux" ]; then
    echo "🐧 Installation de Zsh et Curl via $DETECTED_PM..."
    echo ""

    case $DETECTED_PM in
        apt)
            sudo apt update && sudo apt install -y zsh curl
            ;;
        dnf)
            sudo dnf install -y zsh curl
            ;;
        *)
            echo "❌ Gestionnaire de paquets non supporté pour l'installation auto."
            echo ""
            exit 1
            ;;
    esac
    echo "✅ Zsh et Curl bien/déjà installés."
    echo ""
fi

# Oh My Zsh installation (if not installed)
echo "🌟 Vérification de Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📥 Installation de Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ Oh My Zsh installé."
    echo ""
else
    echo "✅ Oh My Zsh est déjà installé."
    echo ""
fi

# Change default shell
echo "🛠  Vérification du shell par défaut..."
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "🔁 Changement du shell par défaut vers zsh..."
    chsh -s "$(which zsh)"
    echo "✅ Shell par défaut changé en zsh."
    echo ""
else
    echo "✅ Zsh est déjà le shell par défaut."
    echo ""
fi

# Add brew to Zsh path for macOS host
if [ "$DETECTED_OS" == "macOS" ]; then
    echo "🔗 Vérification du PATH pour Homebrew..."
    if ! echo "$PATH" | grep -q "/opt/homebrew/bin"; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "✅ Brew ajouté au PATH."
        echo ""
    else
        echo "✅ Brew est déjà dans le PATH."
        echo ""
    fi
fi

echo "======================================================================"
echo "🎉 Installation terminée ! Zsh et Oh My Zsh sont prêts à l'emploi."
echo "======================================================================"
echo ""
