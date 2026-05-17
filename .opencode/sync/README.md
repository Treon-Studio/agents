# Config Sync

Sync configuration (skills, agents, workflows) from this repository to your own projects.

## Quick Start

### 1. Add as submodule or clone

```bash
# Option A: Git submodule (recommended)
git submodule add https://github.com/Treon-Studio/agents.git .opencode/source

# Option B: Shallow clone
git clone --depth 1 https://github.com/Treon-Studio/agents.git .opencode/source
```

### 2. Copy sync script

```bash
cp .opencode/source/scripts/sync-config.sh scripts/sync-config.sh
chmod +x scripts/sync-config.sh
```

### 3. Copy sync config

```bash
cp .opencode/source/.opencode/sync/sync-config.json .opencode/sync/sync-config.json
```

### 4. Customize sync config

Edit `.opencode/sync/sync-config.json` to choose what to sync:

```json
{
  "source": "https://github.com/Treon-Studio/agents.git",
  "prefix": ".opencode",
  "sync": [
    "skills",
    "agents.json"
  ],
  "exclude": [],
  "branch": "main"
}
```

## Usage

### Check for updates
```bash
./scripts/sync-config.sh --check-only
```

### Dry run (see what would change)
```bash
./scripts/sync-config.sh --dry-run
```

### Sync now
```bash
./scripts/sync-config.sh
```

### After sync
```bash
git add -A
git commit -m "chore: sync config from upstream"
git push
```

## CI/CD Auto-Sync

Add `.github/workflows/sync-check.yml` to your repo for automatic PR creation when updates are available.

The workflow runs daily and creates a PR if there are new updates.

## What gets synced?

| Item | Description |
|------|-------------|
| `skills/*` | All agent skills |
| `agents.json` | Agent configurations |
| `workflows/*.yml` | GitHub Actions workflows |

Exclude items by adding to the `exclude` array in sync config.