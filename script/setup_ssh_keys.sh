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
SSH_KEY_PATH="$SSH_DIR/$SSH_KEY_BASE_NAME"
TARGET_SSH_CONFIG_FILE="$SSH_DIR/config"
DOTFILES_SSH_CONFIG_DIR="../ssh"

# Create .ssh directory if it doesn't exist
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Check if key already exists before create it
if [ -f "$SSH_KEY_PATH" ]; then
    echo "✅ SSH key already exists: $SSH_KEY_PATH"
    echo ""
else
    echo ""
    echo "📝 Generating new SSH key '$SSH_KEY_BASE_NAME'..."
    echo ""
    read -rp "Enter a comment to identify the key: " comment
    echo ""
    ssh-keygen -t ed25519 -C "$comment" -f "$SSH_KEY_PATH" -q
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
else
    echo "Unsupported OS for automatic SSH config file generation: $DETECTED_OS."
    echo "Please configure your ~/.ssh/config manually."
    exit 1
fi

if [ -f "$CONFIG_TEMPLATE_PATH" ]; then
    if [ -f "$TARGET_SSH_CONFIG_FILE" ]; then
        echo "⚠️  A ~/.ssh/config file already exists!"
        read -rp "   Do you want to overwrite it with the new configuration? (y/N): " overwrite_choice
        overwrite_choice=${overwrite_choice:-N} # Default to No

        if [[ "$overwrite_choice" =~ ^[Yy]$ ]]; then
            # Offer to backup
            read -rp "   Do you want to create a backup of the existing config file? (Y/n): " backup_choice
            backup_choice=${backup_choice:-Y} # Default to Yes

            if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
                BACKUP_FILE="${TARGET_SSH_CONFIG_FILE}.bak_$(date +%Y%m%d%H%M%S)"
                cp "$TARGET_SSH_CONFIG_FILE" "$BACKUP_FILE"
                echo "✅ Existing config file backed up to: $BACKUP_FILE"
            fi
            echo "📝 Overwriting $TARGET_SSH_CONFIG_FILE with new configuration..."
            sed "s|IdentityFile ~/.ssh/id_host_name|IdentityFile $SSH_KEY_PATH|g" "$CONFIG_TEMPLATE_PATH" > "$TARGET_SSH_CONFIG_FILE"
            chmod 600 "$TARGET_SSH_CONFIG_FILE"
            echo "✅ SSH config file updated: $TARGET_SSH_CONFIG_FILE"
            echo ""
        else
            echo "❌ Skipping update of $TARGET_SSH_CONFIG_FILE. Please integrate the new key manually if needed."
            echo "Create or update your $TARGET_SSH_CONFIG_FILE with the following entry:"
            echo "   Host github.com"
            echo "     AddKeysToAgent yes"
            echo "     IdentityFile $SSH_KEY_PATH"
            if [ "$DETECTED_OS" == "Darwin" ]; then
                echo "     UseKeychain yes"
            fi
            echo ""
        fi
    else
        echo "📝 Creating $TARGET_SSH_CONFIG_FILE..."
        sed "s|IdentityFile ~/.ssh/id_host_name|IdentityFile $SSH_KEY_PATH|g" "$CONFIG_TEMPLATE_PATH" > "$TARGET_SSH_CONFIG_FILE"
        chmod 600 "$TARGET_SSH_CONFIG_FILE"
        echo "✅ SSH config file created: $TARGET_SSH_CONFIG_FILE"
        echo ""
    fi
else
    echo "⚠️ Error: The SSH configuration template file for $DETECTED_OS was not found at: $CONFIG_TEMPLATE_PATH"
    echo "Please manually create or update your ~/.ssh/config with the following entry:"
    echo "   Host github.com"
    echo "     AddKeysToAgent yes"
    echo "     IdentityFile $SSH_KEY_PATH"
    if [ "$DETECTED_OS" == "Darwin" ]; then
        echo "     UseKeychain yes"
    fi
    echo ""
fi

# ======================================================================
# Final instructions
# ======================================================================

echo "📋 Here is your public key (copy this to GitHub/GitLab/...):"
echo "======================================================================"
cat "$SSH_KEY_PATH.pub"
echo "======================================================================"

echo ""
echo "Go add your key to GitHub and GitLab !"
echo ""

echo "1️⃣  To add it to GitHub:"
echo "   - Go to: https://github.com/settings/keys"
echo "   - Click 'New SSH key'"
echo "   - Title: '$name'"
echo "   - Key type: 'Authentication Key'"
echo "   - Paste the public key above"
echo ""
echo "   To add it to GitLab:"
echo "   - Go to: https://gitlab.com/-/profile/keys"
echo "   - Paste the public key above"
echo ""
echo "2️⃣  Then, test the SSH connexion!"
echo "   Paste it in your terminal"
echo "   ssh -T git@github.com"
echo "   ssh -T git@gitlab.com"
echo ""
