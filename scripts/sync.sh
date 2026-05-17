#!/bin/bash
# sync.sh - Simple sync without dependencies
# Usage: ./sync.sh [--dry-run]

SOURCE_DIR=".opencode/source"
TARGET_PREFIX=".opencode"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Cloning source repo..."
  git clone --depth 1 https://github.com/Treon-Studio/agents.git "$SOURCE_DIR"
fi

cd "$SOURCE_DIR"
git pull origin main
cd ..

echo "Syncing..."
cp -r "$SOURCE_DIR/.opencode/skills" "$TARGET_PREFIX/"
cp "$SOURCE_DIR/.opencode/sync/sync-config.json" "$TARGET_PREFIX/sync/"

echo "Done!"
echo ""
echo "Review: git diff $TARGET_PREFIX/"
echo "Commit: git add -A && git commit -m 'chore: sync config'"