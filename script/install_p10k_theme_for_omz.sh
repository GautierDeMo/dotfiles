#!/bin/bash
set -e

# Function from 'detect os and package manager' script
# shellcheck disable=SC1091
source "$(dirname "$0")/common.sh"
# shellcheck disable=SC1091
source "$(dirname "$0")/detect_os_and_package_manager.sh"
detect_os_and_manager

echo "🔧 Configuration pour : $DETECTED_OS avec $DETECTED_PM"
echo "======================================================================"
echo ""

P10K_README_FONTS_PART='https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#manual-font-installation'
P10K_README_THEME_PART='https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#oh-my-zsh'
P10K_README_CONF_PART='https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#for-new-users'

echo "======================================================================"
echo "🔤 Installation des polices pour P10K"
echo "======================================================================"
echo ""

# MacOS case: Nerd Fonts installation
if [ "$DETECTED_OS" == "macOS" ]; then
    echo "🍎 Vérification de la police MesloLGS NF via Homebrew..."
    echo ""

    # MesloLGS NF police
    if ! brew list font-meslo-lg-nerd-font &> /dev/null; then
        echo "📦 Installation de la police..."
        brew install font-meslo-lg-nerd-font
        echo "✅ police installé."
        echo "⚠️ Allez changer la police de votre terminal, ainsi que celle de votre IDE. ⚠️"
        echo "Voici le lien du README vous indiquant comment faire : $P10K_README_FONTS_PART"
        echo ""
    else
        echo "✅ police déjà installé."
        echo "⚠️ Vérifiez que vous avez changé la police de votre terminal, ainsi que celle de votre IDE. ⚠️"
        echo "Voici le lien du README vous indiquant comment faire : $P10K_README_FONTS_PART"
        echo ""
    fi

# Linux case: Nerd Fonts installation
elif [ "$DETECTED_OS" == "Linux" ]; then
    echo "🐧 Installation de la police MesloLGS NF..."
    echo ""

    FONT_DIR="$HOME/.local/share/fonts"
    TMP_DIR=$(mktemp -d)
    ARCHIVE="$TMP_DIR/Meslo.tar.xz"

    echo "📥 Téléchargement de Meslo Nerd Font..."
    curl -fL -o "$TMP_DIR" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz
    echo "✅ Archive téléchargée."
    echo ""

    echo "📦 Extraction des polices MesloLGS NF..."
    mkdir -p "$FONT_DIR"
    tar -xJf "$ARCHIVE" -C "$TMP_DIR"

    # Only copy MesloLGS NF fonts
    find "$TMP_DIR" -name "MesloLGSNerdFont-*.ttf" -exec cp {} "$FONT_DIR/" \;
    echo "✅ Polices copiées dans $FONT_DIR"
    echo ""

    echo "🔄 Mise à jour du cache des polices..."
    fc-cache -fv
    echo "✅ Cache des polices mis à jour."
    echo ""

    # Verification
    if fc-list | grep -qi "MesloLGS"; then
        echo "✅ Police MesloLGS NF correctement installée et détectée."
    else
        echo "⚠️  Police installée mais non détectée par fc-cache. Redémarrez votre terminal."
    fi
    echo ""

    # Cleaning
    rm -rf "$TMP_DIR"
    echo "🗑️  Dossier temporaire nettoyé."
    echo ""

    echo "⚠️  N'oubliez pas de changer la police de votre terminal et IDE."
    echo "📖 Guide : $P10K_README_FONTS_PART"
    echo ""
fi

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

echo "📁 Répertoire des thèmes : $ZSH_CUSTOM/themes"
echo ""

echo "======================================================================"
echo "🎨 Installation du thème P10K"
echo "======================================================================"
echo ""

# 'P10K' theme installation by cloning its git repo
clone_theme \
  "https://github.com/romkatv/powerlevel10k.git" \
  "powerlevel10k"

echo "⚠️ Ouvrez votre fichier '~/.zshrc', trouvez la ligne qui définit le thème \
et changez sa valeur à 'powerlevel10k/powerlevel10k'"
echo "📖 Guide au cas où : $P10K_README_THEME_PART"
echo ""

echo "Après avoir lancé la commande : 'exec zsh' ou bien 'source ~/.zshrc' pour \
mettre à jour votre conf. ZSH, lors du premier run avec le thème P10K, vous \
passerez par le 'configuration wizard'."
echo "📖 Plus de détails au besoin ici : $P10K_README_CONF_PART"
echo ""
