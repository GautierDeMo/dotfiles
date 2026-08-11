#!/bin/bash

detect_os_and_manager() {
    local os_name
    local package_manager

    echo ""
    echo "======================================================================"
    echo "🔍 Detecting OS and package manager"
    echo "======================================================================"
    echo ""

    # OS detection
    if [[ $(uname -s) == "Darwin"* ]]; then
        os_name="macOS"
        if command -v brew &> /dev/null; then
            package_manager="brew"
            echo "🍎 OS detected: macOS"
            echo "✅ Package manager: Homebrew"
        else
            package_manager="unknown"
            echo "🍎 OS detected: macOS"
            echo "⚠️  Homebrew not detected"
        fi
    elif [[ $(uname -s) == "Linux"* ]]; then
        os_name="Linux"
        echo "🐧 OS detected: Linux"

        # Package manager detection on Linux
        if command -v apt &> /dev/null; then
            package_manager="apt"
            echo "✅ Package manager: apt (Debian/Ubuntu)"
        elif command -v dnf &> /dev/null; then
            package_manager="dnf"
            echo "✅ Package manager: dnf (Fedora/RHEL)"
        else
            package_manager="unknown"
            echo "⚠️  Package manager not detected"
        fi
    else
        os_name="Unknown"
        package_manager="unknown"
        echo "❌ OS not supported or not detected"
    fi

    echo ""
    echo "======================================================================"

    # Export variables for other scripts
    export DETECTED_OS="$os_name"
    export DETECTED_PM="$package_manager"
}

# If the script is called directly, execute the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_os_and_manager
fi
