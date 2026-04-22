# OpenClaw Workstation Bootstrap

Reusable bootstrap for setting up an OpenClaw workstation without rebuilding the same assistant environment from scratch each time.

This repo is meant to be cloned or forked by a human or teammate, then used to scaffold a local OpenClaw workspace with:

- shared workstation defaults
- reusable assistant behavior files
- local-only identity and user config files
- a safe update path for managed files later

## Design goals

- Keep the shared baseline versioned
- Keep local/private/runtime state out of the bootstrap update path
- Make new workstation setup fast
- Make later updates predictable

## Managed vs local files

### Managed files

These come from this repo and can be refreshed later with `scripts/update.sh`:

- `AGENTS.md`
- `SOUL.md`
- `HEARTBEAT.md`

### Local files

These are created from examples on first install if they do not exist, but are not overwritten by updates:

- `IDENTITY.md`
- `USER.md`
- `TOOLS.md`

You should also keep these local/private:

- `memory/`
- `MEMORY.md`
- secrets, tokens, private notes
- live app state and runtime folders

## Quick start

```bash
./scripts/install.sh /path/to/openclaw-workspace
```

If you omit the target path, the current directory is used.

## Update an existing workstation

```bash
./scripts/update.sh /path/to/openclaw-workspace
```

The update script:

- refreshes managed files only
- leaves local identity/private files alone
- creates timestamped backups before replacing managed files

## Typical workflow

1. Clone or fork this repo
2. Run `scripts/install.sh`
3. Edit local files like `IDENTITY.md`, `USER.md`, and `TOOLS.md`
4. Use the workstation normally
5. Later, pull changes in this bootstrap repo and run `scripts/update.sh`

## Repo layout

```text
scripts/
  install.sh
  update.sh
templates/
  managed/
    AGENTS.md
    SOUL.md
    HEARTBEAT.md
  local/
    IDENTITY.md.example
    USER.md.example
    TOOLS.md.example
managed-files.txt
```

## Notes

- The installer and updater are intentionally simple and file-based.
- This repo is the source of truth for shared defaults, not for per-user identity.
- If you want stricter rollout control later, tag releases and sync from known versions instead of always using `main`.
