#!/bin/bash
# sync-config.sh - Sync configuration from upstream repository
# Usage: ./scripts/sync-config.sh [--dry-run] [--check-only]

set -e

SOURCE_REPO="https://github.com/Treon-Studio/agents.git"
SOURCE_DIR=".opencode/source"
CONFIG_FILE=".opencode/sync/sync-config.json"
DRY_RUN=false
CHECK_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --check-only)
      CHECK_ONLY=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  echo "   Run without args to initialize:"
  echo "   ./scripts/sync-config.sh --init"
  exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔄 OpenAgents Config Sync"
echo "========================="

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo "📦 Source directory not found. Cloning..."
  git clone --depth 1 "$SOURCE_REPO" "$SOURCE_DIR"
else
  echo "📥 Pulling latest from upstream..."
  cd "$SOURCE_DIR"
  git fetch origin
  LOCAL=$(git rev-parse HEAD)
  REMOTE=$(git rev-parse origin/main)
  cd - > /dev/null

  if [ "$LOCAL" = "$REMOTE" ]; then
    echo "✅ Already up to date (commit: ${LOCAL:0:7})"
    exit 0
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "🔍 Dry run - would update from ${LOCAL:0:7} to ${REMOTE:0:7}"
    echo ""
    git -C "$SOURCE_DIR" log --oneline ${LOCAL:0:7}..${REMOTE:0:7}
    exit 0
  fi

  if [ "$CHECK_ONLY" = true ]; then
    if [ "$LOCAL" != "$REMOTE" ]; then
      echo "🔔 Update available: ${LOCAL:0:7} → ${REMOTE:0:7}"
      git -C "$SOURCE_DIR" log --oneline ${LOCAL:0:7}..${REMOTE:0:7}
      exit 1
    else
      echo "✅ Up to date"
      exit 0
    fi
  fi

  echo "📦 Updating from ${LOCAL:0:7} to ${REMOTE:0:7}..."
  git -C "$SOURCE_DIR" pull origin main
fi

# Read sync config
SYNCS=$(cat "$CONFIG_FILE" | jq -r '.sync[]' 2>/dev/null || cat "$CONFIG_FILE" | python3 -c "import json,sys; print('\n'.join(json.load(sys.stdin)['sync']))")

echo ""
echo "📋 Syncing files:"
echo "================="

for item in $SYNCS; do
  SOURCE_PATH="$SOURCE_DIR/.opencode/$item"
  TARGET_PATH=".opencode/$item"

  if [ -e "$SOURCE_PATH" ]; then
    if [ -d "$SOURCE_PATH" ]; then
      if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] cp -r $SOURCE_PATH → $TARGET_PATH"
      else
        mkdir -p "$(dirname "$TARGET_PATH")"
        rm -rf "$TARGET_PATH"
        cp -r "$SOURCE_PATH" "$TARGET_PATH"
        echo "  ✅ $item/"
      fi
    else
      if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] cp $SOURCE_PATH → $TARGET_PATH"
      else
        mkdir -p "$(dirname "$TARGET_PATH")"
        cp "$SOURCE_PATH" "$TARGET_PATH"
        echo "  ✅ $item"
      fi
    fi
  else
    echo "  ⚠️  $item (not found, skipping)"
  fi
done

echo ""
if [ "$DRY_RUN" = true ]; then
  echo "🔍 Dry run complete - no changes made"
else
  echo "✅ Sync complete!"
  echo ""
  echo "Next steps:"
  echo "  1. Review changes: git diff .opencode/"
  echo "  2. Commit: git add -A && git commit -m 'chore: sync config from upstream'"
  echo "  3. Push: git push"
fi