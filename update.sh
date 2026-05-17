#!/usr/bin/env bash
#############################################################################
# OpenAgents Updater
# Updates existing .opencode configuration from Treon-Studio/agents
#
# Usage:
#   Interactive:
#     curl -fsSL https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh | bash -s update
#
#   Or download and run:
#     curl -fsSL https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh -o update.sh
#     chmod +x update.sh && ./update.sh
#
#   With options:
#     ./update.sh --dry-run
#     ./update.sh --source https://github.com/owner/repo
#############################################################################

set -e

INSTALLER_URL="https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh"
UPDATE_SCRIPT="/tmp/openagents-update-$$"

echo "📥 Downloading updater..."
if command -v curl &>/dev/null; then
    curl -fsSL "$INSTALLER_URL" -o "$UPDATE_SCRIPT"
elif command -v wget &>/dev/null; then
    wget -q "$INSTALLER_URL" -O "$UPDATE_SCRIPT"
else
    echo "Error: curl or wget required"
    exit 1
fi

chmod +x "$UPDATE_SCRIPT"
exec "$UPDATE_SCRIPT" --update "$@"