#!/usr/bin/env bash
# fix-permissions.sh - macOS Permission Solver v1.1
# Fixes common macOS permission issues, clears quarantine flags,
# resets TCC privacy settings, and deep-cleans stuck apps.
# Works in bash OR zsh. No zsh required.
# Usage: bash fix-permissions.sh
# Repo: https://github.com/toronto192020/macos-permission-solver

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${CYAN}\u2192${NC} $*"; }
ok()   { echo -e "${GREEN}\u2713${NC} $*"; }
warn() { echo -e "${YELLOW}\u26a0${NC} $*"; }
fail() { echo -e "${RED}\u2717${NC} $*"; }

echo ""
echo "\u2554\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2557"
echo "\u2551     macOS Permission Solver v1.1         \u2551"
echo "\u255a\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u255d"
echo ""

# --- 1. Fix home directory ownership ---
log "Fixing home directory ownership..."
if sudo chown -R "$USER:staff" "$HOME" 2>/dev/null; then
  ok "Home dir ownership fixed"
else
  warn "Could not fix home dir ownership (SIP may be blocking)"
fi

# --- 2. Fix Downloads/Documents permissions ---
log "Ensuring user dirs are readable..."
chmod -R u+rw "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" 2>/dev/null && ok "User dirs OK" || warn "Some dirs skipped"

# --- 3. Clear quarantine flags from /Applications ---
log "Clearing quarantine flags from /Applications..."
if sudo xattr -rd com.apple.quarantine /Applications/ 2>/dev/null; then
  ok "Quarantine flags cleared"
else
  warn "Some quarantine flags could not be cleared"
fi

# --- 4. Rebuild Launch Services DB (fixes broken app icons/associations) ---
log "Rebuilding Launch Services database (this takes ~10s)..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -kill -r -domain local -domain system -domain user 2>/dev/null \
  && ok "Launch Services rebuilt" || warn "Launch Services rebuild failed"

# --- 5. Restart Dock + Finder to pick up changes ---
log "Restarting Dock and Finder..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
ok "Dock + Finder restarted"

# --- 6. Fix broken symlinks in /usr/local ---
log "Checking for broken symlinks in /usr/local..."
BROKEN=$(find /usr/local -maxdepth 3 -type l ! -exec test -e {} \; -print 2>/dev/null || true)
if [ -n "$BROKEN" ]; then
  warn "Broken symlinks found:"
  echo "$BROKEN"
  echo "Remove them? (yes/N):"
  read -r CONFIRM_SYM
  if [ "$CONFIRM_SYM" = "yes" ]; then
    echo "$BROKEN" | xargs rm -f 2>/dev/null && ok "Broken symlinks removed"
  fi
else
  ok "No broken symlinks found in /usr/local"
fi

# --- 7. TCC reset for a specific app ---
echo ""
echo "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
echo "  TCC (Privacy) Permission Reset"
echo "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
echo "Enter bundle ID to reset (e.g. com.apple.Terminal) or press Enter to skip:"
read -r BUNDLE_ID
if [ -n "$BUNDLE_ID" ]; then
  log "Resetting TCC for $BUNDLE_ID..."
  if tccutil reset All "$BUNDLE_ID" 2>/dev/null; then
    ok "TCC reset for $BUNDLE_ID - it will ask for permissions again on next launch"
  else
    warn "TCC reset failed - may need SIP disabled for full reset"
  fi
fi

# --- 8. Stuck App Deep Cleaner ---
echo ""
echo "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
echo "  Stuck App Deep Cleaner"
echo "\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
echo "App name to fully remove? (e.g. Spotify) [Enter to skip]:"
read -r APP_NAME

if [ -n "$APP_NAME" ]; then
  log "Killing any running $APP_NAME processes..."
  pkill -fi "$APP_NAME" 2>/dev/null || true
  sleep 1

  log "Scanning all known Library paths for $APP_NAME files..."
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
      -maxdepth 3 \
      -iname "*${APP_NAME}*" \
      2>/dev/null || true
  )

  if [ -z "$FOUND_FILES" ]; then
    warn "No files found for '$APP_NAME'"
  else
    echo ""
    echo "Files found:"
    echo "$FOUND_FILES"
    echo ""
    echo "PERMANENTLY delete all of the above? Type 'yes' to confirm:"
    read -r CONFIRM_DEL
    if [ "$CONFIRM_DEL" = "yes" ]; then
      echo "$FOUND_FILES" | while IFS= read -r f; do
        sudo rm -rf "$f" 2>/dev/null && log "Removed: $f" || warn "Could not remove: $f"
      done

      log "Checking pkgutil for installer package records..."
      pkgutil --pkgs 2>/dev/null | grep -i "$APP_NAME" | while IFS= read -r pkg; do
        log "Forgetting package: $pkg"
        sudo pkgutil --forget "$pkg" 2>/dev/null && ok "Forgotten: $pkg" || warn "Could not forget: $pkg"
      done

      ok "Deep clean complete for: $APP_NAME"
    else
      log "Skipped deletion."
    fi
  fi
fi

echo ""
ok "All done. Reboot recommended if you fixed TCC or ownership issues."
echo ""
