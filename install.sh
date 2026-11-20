#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_FILE="$HOME/.pocketmac.zsh"
ZSHRC="$HOME/.zshrc"
SOURCE_LINE='[ -f "$HOME/.pocketmac.zsh" ] && source "$HOME/.pocketmac.zsh"'

echo "Installing PocketMac shell commands..."
cp "$SCRIPT_DIR/pocketmac.zsh" "$TARGET_FILE"

touch "$ZSHRC"
if ! grep -Fq '.pocketmac.zsh' "$ZSHRC"; then
  {
    echo ""
    echo "# PocketMac: Reversible Vacation Mode toggles"
    echo "$SOURCE_LINE"
  } >> "$ZSHRC"
  echo "Added PocketMac loader to $ZSHRC"
else
  echo "PocketMac loader already present in $ZSHRC"
fi

echo ""
echo "Done! Next steps:"
echo "  1. Reload your shell:          source ~/.zshrc"
echo "  2. Verify normal sleep status: pocket-status"
echo "  3. Enable Wake on Network:     sudo pmset -a womp 1"
echo "  4. Install Tailscale (if needed): brew install --cask tailscale-app && open -a Tailscale"
echo "  5. View your connection info:  pocket-info"
