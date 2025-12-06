#!/bin/bash

detect_os_and_manager() {
    local os_name
    local package_manager

    # OS detection
    if [[ "$OSTYPE" == "darwin"* ]]; then
        os_name="macOS"
        if command -v brew &> /dev/null; then
            package_manager="brew"
        else
            package_manager="unknown (brew not installed)"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os_name="Linux"

        # Package Manager detection on Linux
        if command -v apt &> /dev/null; then
            package_manager="apt for Debian, Ubuntu, Pop!_OS, Mint"
        elif command -v dnf &> /dev/null; then
            package_manager="dnf for Fedora, RHEL, CentOS 8+"
        elif command -v pacman &> /dev/null; then
            package_manager="pacman for Arch Linux, Manjaro"
        elif command -v yum &> /dev/null; then
            package_manager="yum for Vieux CentOS/RHEL"
        elif command -v zypper &> /dev/null; then
            package_manager="zypper for OpenSUSE"
        elif command -v apk &> /dev/null; then
            package_manager="apk for Alpine Linux"
        else
            package_manager="unknown"
        fi
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        os_name="Windows"
        package_manager="winget/choco"
    else
        os_name="Unknown"
        package_manager="unknown"
    fi

    echo "OS: $os_name"
    echo "Manager: $package_manager"

    # Variables exportation needed for global script
    export DETECTED_OS="$os_name"
    export DETECTED_PM="$package_manager"
}

# If the script is called alone, we call the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_os_and_manager
fi
