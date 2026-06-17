#!/usr/bin/env bash
# quick-fix.sh - Non-interactive one-shot permission repair
# Run this when you just want everything fixed NOW with no prompts.
# Usage: bash quick-fix.sh

set -euo pipefail

echo "[macos-permission-solver] Running quick non-interactive fix..."

# Fix home dir ownership
sudo chown -R "$USER:staff" "$HOME" 2>/dev/null || true

# Clear quarantine
sudo xattr -rd com.apple.quarantine /Applications/ 2>/dev/null || true

# Rebuild Launch Services
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -kill -r -domain local -domain system -domain user 2>/dev/null || true

# Restart Dock + Finder
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

echo "[macos-permission-solver] Quick fix complete. Reboot if issues persist."
