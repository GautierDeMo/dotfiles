#!/bin/bash
set -e

# Function from 'detect os and package manager' script
# shellcheck disable=SC1091
source "$(dirname "$0")/detect_os_and_package_manager.sh"
detect_os_and_manager

# shellcheck disable=SC2153
echo "-----> Configuration pour : $DETECTED_OS avec $DETECTED_PM"

# Zsh installation logic
if [ "$DETECTED_OS" == "macOS" ]; then

    # MacOS case : Check Homebrew first
    if ! command -v brew &> /dev/null; then
        echo "-----> Homebrew non trouvé. Installation en cours..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add brew to path temporary for what's after
        eval "$(/opt/homebrew/bin/brew shellenv)"
        DETECTED_PM="brew"
    else
        echo "✅ Brew déjà installé."
    fi

    echo "-----> Installation de Zsh via Homebrew..."
    if ! command -v zsh &> /dev/null; then
        echo "-----> Zsh non trouvé. Installation en cours..."
        brew install zsh
    else
        echo "✅ Zsh est déjà installé."
    fi

    # Linux case : Use the good package manager
elif [ "$DETECTED_OS" == "Linux" ]; then
    echo "-----> Installation de 'Zsh' et 'Curl' via $DETECTED_PM..."

    case $DETECTED_PM in
        apt)
            sudo apt update && sudo apt install -y zsh curl
            ;;
        dnf)
            sudo dnf install -y zsh curl
            ;;
        *)
            echo "❌ Gestionnaire de paquets non supporté pour l'installation auto."
            exit 1
            ;;
    esac
fi

# Oh My Zsh installation (if not installed)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "-----> Installation de Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh est déjà installé."
fi

# Change default shell
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "-----> Changement du shell par défaut vers zsh..."
    chsh -s "$(which zsh)"
else
    echo "✅ Zsh est déjà le shell par défaut."
fi

# Add brew to Zsh path for MacOS host
if [ "$DETECTED_OS" == "macOS" ]; then
    if ! echo "$PATH" | grep -q "/opt/homebrew/bin"; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "✅ Brew ajouté au path Zsh."
    else
        echo "✅ Brew est déjà dans le PATH."
    fi
fi

echo "🎉 Installation terminée ! Zsh et Oh My Zsh sont prêts à l'emploi."
