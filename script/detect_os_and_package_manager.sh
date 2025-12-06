#!/bin/bash

detect_os_and_manager() {
    local os_name
    local package_manager

    echo ""
    echo "======================================================================"
    echo "🔍 Détection de l'OS et du gestionnaire de paquets"
    echo "======================================================================"
    echo ""

    # OS detection
    if [[ "$OSTYPE" == "darwin"* ]]; then
        os_name="macOS"
        if command -v brew &> /dev/null; then
            package_manager="brew"
            echo "🍎 OS détecté : macOS"
            echo "✅ Gestionnaire : Homebrew"
        else
            package_manager="unknown (brew not installed)"
            echo "🍎 OS détecté : macOS"
            echo "⚠️  Homebrew non détecté"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os_name="Linux"
        echo "🐧 OS détecté : Linux"

        # Package Manager detection on Linux
        if command -v apt &> /dev/null; then
            package_manager="apt for Debian, Ubuntu, Pop!_OS, Mint"
            echo "✅ Gestionnaire : apt"
        elif command -v dnf &> /dev/null; then
            package_manager="dnf for Fedora, RHEL, CentOS 8+"
            echo "✅ Gestionnaire : dnf"
        else
            package_manager="unknown"
            echo "⚠️  Gestionnaire non détecté"
        fi
    else
        os_name="Unknown"
        package_manager="unknown"
        echo "❌ OS non supporté ou non détecté"
    fi

    echo ""
    echo "Résumé : OS=$os_name | PM=$package_manager"
    echo "======================================================================"
    echo ""

    # Variables exportation needed for global script
    export DETECTED_OS="$os_name"
    export DETECTED_PM="$package_manager"
}

# If the script is called alone, we call the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_os_and_manager
fi
