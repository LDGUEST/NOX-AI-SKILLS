---
name: update
description: Checks for NOX AI Skills updates and installs them from the CLI. Use when the skill pack may be outdated or a new release has been announced.
---

Check for NOX AI Skills updates and install them from the CLI.

## Process

1. **Find the NOX repo** — check these locations in order:
   - `$NOX_SKILLS_DIR` (if set)
   - `$HOME/.nox`
   - `$HOME/NOX`
   - On Windows: `C:\Users\Admin\.cursor\projects\NOX`
   - If not found, offer to clone: `git clone https://github.com/LDGUEST/NOX.git $HOME/.nox`

2. **Check current version** — run from the repo directory:
   ```bash
   cd <repo_path>
   LOCAL_HASH=$(git rev-parse --short HEAD)
   LOCAL_DATE=$(git log -1 --format='%ci' HEAD | cut -d' ' -f1)
   git fetch origin main --quiet
   REMOTE_HASH=$(git rev-parse --short origin/main)
   ```

3. **Compare** — if `LOCAL_HASH == REMOTE_HASH`, report "Already up to date" and stop.

4. **Show what's new** — display commits between local and remote.

5. **Ask to proceed** — confirm with the user before updating.

6. **Pull and reinstall**:
   ```bash
   cd <repo_path>
   git pull origin main
   bash install.sh
   ```

7. **Report result** — show old hash, new hash, and prompt to restart CLI session.

---
Nox
