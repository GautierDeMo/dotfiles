#!/bin/bash
set -e

# Import detection function
# shellcheck disable=SC1091
source "$(dirname "$0")/detect_os_and_package_manager.sh"
detect_os_and_manager

echo "🔑 SSH Keys Setup for: $DETECTED_OS with $DETECTED_PM"
echo "======================================================================"
echo ""

SSH_DIR="$HOME/.ssh"
read -rp "Name your key (e.g., personal, work): " name
echo ""

# Validate key name to prevent path issues
if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: The key name must only contain letters, numbers, hyphens, and underscores."
    exit 1
fi

SSH_KEY_BASE_NAME="id_$name"
SSH_KEY="$SSH_DIR/$SSH_KEY_BASE_NAME"
TARGET_SSH_CONFIG="$SSH_DIR/config"
DOTFILES_SSH_CONFIG_DIR="/home/gdemauroy/Workspace/Private/dotfiles/ssh"

# Create .ssh directory if it doesn't exist
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Check if key already exists
if [ -f "$SSH_KEY" ]; then
    echo "✅ SSH key already exists: $SSH_KEY"
    echo ""
else
    echo ""
    echo "📝 Generating new SSH key '$SSH_KEY_BASE_NAME'..."
    echo ""
    read -rp "Enter your email for the key: " email
    echo ""
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY" -q
    echo ""
    echo "✅ SSH key generated."
    echo ""
fi

# ======================================================================
# Configure ~/.ssh/config based on the OS
# ======================================================================
CONFIG_TEMPLATE_PATH=""

if [ "$DETECTED_OS" == "macOS" ]; then
    echo "OS detected: macOS. Using macOS configuration template."
    CONFIG_TEMPLATE_PATH="$DOTFILES_SSH_CONFIG_DIR/config_macos"
elif [ "$DETECTED_OS" == "Linux" ]; then
    echo "OS detected: Linux. Using Linux configuration template."
    CONFIG_TEMPLATE_PATH="$DOTFILES_SSH_CONFIG_DIR/config_linux"

    # Check and install keychain if not present
    if ! command -v keychain &> /dev/null; then
        echo "📝 Keychain not found. Installing keychain..."
        case "$DETECTED_PM" in
            apt)
                sudo apt update && sudo apt install -y keychain
                ;;
            dnf)
                sudo dnf install -y keychain
                ;;
            *)
                echo "⚠️  Unsupported package manager '$DETECTED_PM' for auto-installing keychain. Please install it manually."
                ;;
        esac
        if command -v keychain &> /dev/null; then
            echo "✅ Keychain installed."
        else
            echo "❌ Failed to install keychain. Please install it manually."
        fi
    else
        echo "✅ Keychain is already installed."
    fi
else
    echo "Unsupported OS for automatic SSH config file generation: $DETECTED_OS."
    echo "Please configure your ~/.ssh/config manually."
    exit 1
fi

if [ -f "$CONFIG_TEMPLATE_PATH" ]; then
    echo "📝 Creating/Updating $TARGET_SSH_CONFIG..."
    sed "s|IdentityFile ~/.ssh/id_host_name|IdentityFile $SSH_KEY|g" "$CONFIG_TEMPLATE_PATH" > "$TARGET_SSH_CONFIG"
    chmod 600 "$TARGET_SSH_CONFIG"
    echo "✅ SSH config file created/updated: $TARGET_SSH_CONFIG"
    echo ""
else
    echo "⚠️ Error: The SSH configuration template file for $DETECTED_OS was not found at: $CONFIG_TEMPLATE_PATH"
    echo "Please manually create or update your ~/.ssh/config with the following entry:"
    echo "   Host github.com"
    echo "     AddKeysToAgent yes"
    if [ "$DETECTED_OS" == "Darwin" ]; then
        echo "     UseKeychain yes"
    fi
    echo "     IdentityFile $SSH_KEY"
    echo ""
fi

# ======================================================================
# Final instructions
# ======================================================================

# Display public key
echo "📋 Your public key (copy this to GitHub/GitLab):"
echo "======================================================================"
cat "$SSH_KEY.pub"
echo "======================================================================"
echo ""

echo "📝 Next steps:"
echo ""
echo "1️⃣  Add to GitHub:"
echo "   - Go to: https://github.com/settings/keys"
echo "   - Click 'New SSH key'"
echo "   - Title: '$name'"
echo "   - Key type: 'Authentication Key'"
echo "   - Paste the key above"
echo ""
echo "   Also add to GitLab if you use it:"
echo "   - Go to: https://gitlab.com/-/profile/keys"
echo "   - Paste the key above"
echo ""
echo "2️⃣  Test connection:"
echo "   ssh -T git@github.com"
echo ""
echo "3️⃣  Restart your terminal for SSH keys to load automatically."
echo "    (On macOS, you might need to run 'ssh-add --apple-use-keychain $SSH_KEY' manually if the key is not auto-added to the keychain.)"
echo ""
