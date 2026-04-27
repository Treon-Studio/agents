# OpenAgents Control

> Curated AI agent configurations, contexts, skills, and tools for the OpenCode ecosystem.

This repository contains the `.opencode` configuration used by [Treon Studio](https://github.com/Treon-Studio) projects. It includes agents, subagents, commands, skills, context files, and tooling — all installable with a single command.

---

## Quick Start

Install everything with one line:

```bash
curl -fsSL https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh | bash -s full
```

Or pick a profile:

```bash
# Core agents + essential standards
curl -fsSL ... | bash -s minimal

# Core agents, contexts, and commands
curl -fsSL ... | bash -s essential

# Development-focused tools, subagents, and skills
curl -fsSL ... | bash -s developer

# SEO & content agents
curl -fsSL ... | bash -s content
```

> Replace `...` with the full `https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh` URL.

---

## What's Inside

| Directory | Contents |
|-----------|----------|
| `agent/` | Core agents (code reviewer, security auditor, docs writer, etc.) |
| `agent/subagents/` | Specialist subagents (frontend, mobile, devops, testing, etc.) |
| `agent/content/` | SEO & content agents (backlinks, clusters, schema, local SEO, etc.) |
| `context/` | Domain-specific context files (development, UI, project intelligence) |
| `command/` | CLI commands and scripts (validate, optimize, commit helpers) |
| `skills/` | Reusable skill modules (task management, Context7 library registry) |
| `config/` | Agent metadata and configuration |
| `tool/` | Utility tools (env, Gemini integration) |
| `plugin/` | Plugin scripts |

---

## Installation Profiles

Choose a profile based on what you need:

| Profile | Files | Description |
|---------|-------|-------------|
| **minimal** | ~19 | Core agents + basic standards only |
| **essential** | ~80 | Core agents, contexts, commands |
| **developer** | ~140 | Dev tools, subagents, skills |
| **content** | ~60 | SEO & content agents, UI context |
| **full** | 244 | Everything |

### Interactive Install

Run without arguments to choose location and profile interactively:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh)
```

### Custom Directory

```bash
curl -fsSL ... | bash -s developer --install-dir ~/.config/opencode
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `AGENTS_BRANCH` | `main` | Git branch to install from |
| `AGENTS_INSTALL_DIR` | `.opencode` | Default installation directory |

Example:

```bash
export AGENTS_INSTALL_DIR=~/.config/opencode
curl -fsSL ... | bash -s full
```

---

## Requirements

- **Bash** 3.2+
- **curl**
- **tar**

Works on macOS, Linux, and Windows (Git Bash / WSL).

---

## Manual Usage

Clone and run locally:

```bash
git clone https://github.com/Treon-Studio/agents.git
cd agents
bash install.sh developer --install-dir ./my-opencode
```

When running from the cloned repo, the installer uses the local `.opencode` directory directly — no download needed.

---

## Project Context

This repository also includes `AGENTS.md` — project-specific context for the [Hunivo](https://github.com/Treon-Studio) property management SaaS. AI agents use this file to understand:

- Tech stack (Hono, Astro, React Native, Drizzle, etc.)
- Project structure and conventions
- Database rules and API patterns
- Business constraints

---

## Contributing

1. Add or update files in `.opencode/`
2. Test the installer locally: `bash install.sh full --install-dir /tmp/test`
3. Open a pull request

---

## License

MIT © Treon Studio
