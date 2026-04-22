# OpenClaw Workstation Bootstrap

Reusable bootstrap for setting up Demondog OpenClaw workstations without rebuilding the same assistant environment from scratch each time.

This repo is meant to be cloned or forked by a human or teammate, then used to scaffold a local OpenClaw workspace with:

- shared workstation defaults
- reusable assistant behavior files
- Demondog company context docs
- local-only identity and user config files
- a safe update path for managed files later

## Design goals

- Keep the shared baseline versioned
- Keep local/private/runtime state out of the bootstrap update path
- Make new workstation setup fast
- Make later updates predictable
- Allow workstation-specific behavior to extend shared files safely

## Managed vs local files

### Generated managed files

These are rendered from this repo and can be refreshed later with `scripts/update.sh`:

- `AGENTS.md`
- `SOUL.md`
- `HEARTBEAT.md`

### Managed shared content

These are synced from this repo into the workstation as shared source-of-truth content:

- `company/`

### Local extension files

These are optional local fragments that get appended to the matching managed file when present:

- `AGENTS.local.md`
- `SOUL.local.md`
- `HEARTBEAT.local.md`

This lets a workstation keep local instructions while still inheriting updates from the shared base.

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

- refreshes generated managed files
- syncs shared company docs under `company/`
- preserves local extension files
- leaves local identity/private files alone
- creates timestamped backups before replacing generated files or synced company docs

## Typical workflow

1. Clone or fork this repo
2. Run `scripts/install.sh`
3. Edit local files like `IDENTITY.md`, `USER.md`, and `TOOLS.md`
4. Add workstation-specific instructions to `AGENTS.local.md` or `SOUL.local.md` if needed
5. Use the workstation normally
6. Later, pull changes in this bootstrap repo and run `scripts/update.sh`

## Repo layout

```text
company/
  README.md
  demondog-overview.md
  values.md
  positioning.md
  tone-of-voice.md
  ideal-clients.md
  faq.md
  services/
  offers/
  case-studies/
scripts/
  install.sh
  update.sh
templates/
  managed/
    AGENTS.md
    SOUL.md
    HEARTBEAT.md
  local/
    AGENTS.local.md.example
    SOUL.local.md.example
    HEARTBEAT.local.md.example
    IDENTITY.md.example
    USER.md.example
    TOOLS.md.example
managed-files.txt
```

## Notes

- The installer and updater are intentionally simple and file-based.
- This repo is the source of truth for shared defaults, not for per-user identity.
- Managed files are rendered from the shared base plus optional local fragments.
- If you want stricter rollout control later, tag releases and sync from known versions instead of always using `main`.
