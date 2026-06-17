# macOS Permission Solver

Fixes common macOS permission issues, clears quarantine flags, resets TCC privacy settings, and deep-cleans stuck apps. Works in **bash or zsh** on macOS 12+.

No homebrew. No Python. No dependencies. Pure bash.

## Scripts

| Script | Purpose |
|--------|--------|
| `fix-permissions.sh` | Full interactive permission repair + TCC reset + stuck app cleaner |
| `quick-fix.sh` | Non-interactive one-shot fix (good for automation / n8n triggers) |
| `uninstall-app.sh "AppName"` | Fully remove a stubborn app and all its library files |

## Quick Start

```bash
# Clone
git clone https://github.com/toronto192020/macos-permission-solver.git
cd macos-permission-solver

# Make executable
chmod +x *.sh

# Run full interactive fix
bash fix-permissions.sh

# OR: one-shot non-interactive (safe to automate)
bash quick-fix.sh

# OR: remove a specific stuck app
bash uninstall-app.sh "Spotify"
```

## What it fixes

- Home directory ownership (`chown -R $USER:staff ~/`)
- Quarantine flags on apps (`xattr -rd com.apple.quarantine`)
- Launch Services database (broken icons, wrong app associations)
- Broken symlinks in `/usr/local`
- TCC privacy permission reset per app (`tccutil reset All <bundle>`)
- Full deep-clean of stuck/partially-uninstalled apps (Library, Containers, Caches, Prefs, pkgutil records)

## Automation

`quick-fix.sh` is designed to be called from n8n, cron, or a shell trigger with no interaction required:

```bash
# cron: run at 3am daily
0 3 * * * /path/to/quick-fix.sh >> /var/log/macos-permission-solver.log 2>&1
```

## Limitations

- Full TCC reset (`tccutil reset All`) may require SIP to be disabled for system-level apps
- Some `/System` paths are protected by SIP and cannot be modified
- Run with `sudo` available for best results

## License

MIT
