#!/bin/bash
set -e

# Function from 'detect os and package manager' script
# shellcheck disable=SC1091
source "$(dirname "$0")/detect_os_and_package_manager.sh"
detect_os_and_manager

echo ""
echo "======================================================================"
# shellcheck disable=SC2153
echo "🔧 Configuration pour : $DETECTED_OS avec $DETECTED_PM"
echo "======================================================================"
echo ""

# ===================================================================
# Plugins installation logic when package manager is needed
# ===================================================================

# MacOS case:
if [ "$DETECTED_OS" == "macOS" ]; then
    echo "🍎 Vérification d'autojump et fzf via Homebrew..."
    echo ""

    # Autojump
    if ! brew list autojump &> /dev/null; then
        echo "📦 Installation d'autojump..."
        brew install autojump
        echo "✅ autojump installé."
        echo ""
    else
        echo "✅ autojump déjà installé."
        echo ""
    fi

    # FZF
    if ! brew list fzf &> /dev/null; then
        echo "🔍 Installation de fzf..."
        brew install fzf
        echo "✅ fzf installé."
        echo ""
    else
        echo "✅ fzf déjà installé."
        echo ""
    fi

#  Linux case:
elif [ "$DETECTED_OS" == "Linux" ]; then
    echo "🐧 Installation d'autojump et fzf via $DETECTED_PM..."
    echo ""

    case $DETECTED_PM in
        apt)
            sudo apt update && sudo apt install -y autojump fzf
            echo ""
            echo "✅ autojump et fzf installés."
            echo ""
            ;;
        dnf)
            sudo dnf install -y autojump-zsh fzf
            echo ""
            echo "✅ autojump et fzf installés."
            echo ""
            ;;
        *)
            echo "❌ Gestionnaire de paquets non supporté pour l'installation auto."
            echo ""
            exit 1
            ;;
    esac
fi

# ===================================================================
# setting the var if needed
# ===================================================================

echo "----------------------------------------------------------------------"
echo "🔍 Vérification de l'environnement Oh My Zsh..."
echo "----------------------------------------------------------------------"
echo ""

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
if [ ! -d "$ZSH_CUSTOM" ]; then
  echo "❌ Oh My Zsh n'est pas installé ($ZSH_CUSTOM introuvable)."
  echo "   Installez Oh My Zsh avant d'exécuter la suite de ce script."
  echo ""
  exit 1
fi

echo "📁 Répertoire des plugins : $ZSH_CUSTOM/plugins"
echo ""

# Clones a Zsh plugin from a given Git repository.
# It checks if the plugin directory already exists before cloning.
#
# @param $1 The URL of the Git repository to clone.
# @param $2 The destination path where the plugin should be cloned.
clone_plugin() {
  local repo=$1
  local name=$2
  local dir="$ZSH_CUSTOM/plugins/$name"

  if [ ! -d "$dir" ]; then
    echo "📥 Installation de $name..."
    if git clone "$repo" "$dir"; then
      echo "✅ $name installé."
      echo ""
    else
      echo "❌ Erreur lors de l'installation de $name."
      echo ""
      return 1
    fi
  else
    echo "✅ $name déjà installé."
    echo ""
  fi
}

# ===================================================================
# Oh My Zsh plugins installation
# ===================================================================

echo "======================================================================"
echo "🧩 Installation des plugins Oh My Zsh personnalisés"
echo "======================================================================"
echo ""

# 'zsh-autosuggestions' plugin installation by cloning its git repo
clone_plugin \
  "https://github.com/zsh-users/zsh-autosuggestions" \
  "zsh-autosuggestions"

# 'fast-syntax-highlighting' plugin installation by cloning its git repo
clone_plugin \
  "https://github.com/zdharma-continuum/fast-syntax-highlighting" \
  "fast-syntax-highlighting"

# 'you-should-use' plugin installation by cloning its git repo
clone_plugin \
  "https://github.com/MichaelAquilina/zsh-you-should-use" \
  "you-should-use"

echo "======================================================================"
echo "🎉 Installation des plugins terminée !"
echo "======================================================================"
echo ""
