#!/usr/bin/env bash
# uninstall-app.sh - Fully remove a stubborn app and all its files
# Usage: bash uninstall-app.sh "AppName"
# Example: bash uninstall-app.sh "Spotify"

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 AppName"
  exit 1
fi

APP_NAME="$1"

echo "[uninstall] Killing processes matching: $APP_NAME"
pkill -fi "$APP_NAME" 2>/dev/null || true
sleep 1

echo "[uninstall] Scanning for all files related to: $APP_NAME"
FOUND_FILES=$(
  find \
    "$HOME/Library/Application Support" \
    "$HOME/Library/Preferences" \
    "$HOME/Library/Caches" \
    "$HOME/Library/Logs" \
    "$HOME/Library/Containers" \
    "$HOME/Library/Group Containers" \
    "$HOME/Applications" \
    "/Applications" \
    "/Library/Application Support" \
    "/Library/Caches" \
    "/Library/Preferences" \
    -maxdepth 4 \
    -iname "*${APP_NAME}*" \
    2>/dev/null || true
)

if [ -z "$FOUND_FILES" ]; then
  echo "[uninstall] No files found for '$APP_NAME'. Already clean?"
  exit 0
fi

echo "[uninstall] Found:"
echo "$FOUND_FILES"
echo ""
echo "[uninstall] Type 'yes' to permanently delete all above:"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "[uninstall] Aborted."
  exit 0
fi

echo "$FOUND_FILES" | while IFS= read -r f; do
  sudo rm -rf "$f" 2>/dev/null && echo "  Removed: $f" || echo "  WARN: could not remove $f"
done

echo "[uninstall] Cleaning up pkgutil package records..."
pkgutil --pkgs 2>/dev/null | grep -i "$APP_NAME" | while IFS= read -r pkg; do
  sudo pkgutil --forget "$pkg" 2>/dev/null && echo "  Forgotten pkg: $pkg" || true
done

echo "[uninstall] Done. '$APP_NAME' fully removed."
