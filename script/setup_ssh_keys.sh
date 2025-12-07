#!/bin/bash
set -e

echo ""
echo "======================================================================"
echo "🔑 SSH Keys Setup"
echo "======================================================================"
echo ""

SSH_DIR="$HOME/.ssh"
read -rp "Name your key: " name
echo ""
SSH_KEY="$SSH_DIR/id_$name"

# Create .ssh directory if it doesn't exist
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Check if key already exists
if [ -f "$SSH_KEY" ]; then
    echo "✅ SSH key already exists: $SSH_KEY"
    echo ""
else
    echo ""
    echo "📝 Generating new SSH key..."
    echo ""
    read -rp "Enter your email: " email
    echo ""
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY"
    echo ""
    echo "✅ SSH key generated."
    echo ""
fi

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
echo "2️⃣  Update ~/.ssh/config:"
echo "   Host github.com"
echo "     AddKeysToAgent yes"
echo "     UseKeychain yes        # macOS only"
echo "     IdentityFile ~/.ssh/$name"
echo ""
echo "3️⃣  Test connection:"
echo "   ssh -T git@github.com"
echo ""
echo "4️⃣  Restart your terminal (next time you open it, SSH keys auto-load)"
echo ""
