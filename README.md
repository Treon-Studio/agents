<div align="center">

# OpenAgents Control

**Curated AI agent configurations, contexts, skills, and tools for the OpenCode ecosystem.**

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/Treon-Studio/agents)
[![Bash](https://img.shields.io/badge/bash-3.2%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)](https://github.com/Treon-Studio/agents)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

</div>

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [What Is `.opencode`?](#what-is-opencode)
- [Repository Structure](#repository-structure)
- [Installation Profiles](#installation-profiles)
  - [Profile Comparison](#profile-comparison)
  - [When to Use Each Profile](#when-to-use-each-profile)
- [Installation Methods](#installation-methods)
  - [One-Liner (Non-Interactive)](#one-liner-non-interactive)
  - [Interactive Mode](#interactive-mode)
  - [Local Clone](#local-clone)
- [Configuration](#configuration)
  - [Environment Variables](#environment-variables)
  - [Custom Installation Directory](#custom-installation-directory)
- [How It Works](#how-it-works)
- [What's Inside](#whats-inside)
  - [Agents](#agents)
  - [Subagents](#subagents)
  - [Context Files](#context-files)
  - [Commands](#commands)
  - [Skills](#skills)
  - [Tools & Plugins](#tools--plugins)
- [Project Context (AGENTS.md)](#project-context-agentsmd)
- [Requirements](#requirements)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [FAQ](#faq)
- [License](#license)

---

## Overview

OpenAgents Control is the central repository for AI agent configurations used by [Treon Studio](https://github.com/Treon-Studio). It provides a complete `.opencode` setup — agents, subagents, commands, skills, context files, and tooling — that can be installed anywhere with a single command.

Whether you're working on a full-stack SaaS, optimizing SEO content, or reviewing code, there's a profile tailored for your workflow.

### Key Features

- **One-command installation** — `curl | bash` and you're done
- **5 installation profiles** — from minimal (~19 files) to full (244 files)
- **Cross-platform** — macOS, Linux, Windows (Git Bash / WSL)
- **Smart installer** — auto-detects local repo, skips existing files, supports backups
- **Modular design** — install only what you need

---

## Quick Start

### Install Everything

```bash
curl -fsSL https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh | bash -s full
```

### Install for Development Work

```bash
curl -fsSL https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh | bash -s developer
```

### Interactive Installation

Not sure what you need? Run the installer without arguments:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh)
```

You'll be guided through:
1. Choosing the installation location (local, global, or custom)
2. Selecting a profile (minimal, essential, developer, content, full)
3. Reviewing what will be installed before confirming

---

## What Is `.opencode`?

`.opencode` is a convention for storing AI agent configurations in a project repository. When AI assistants (like Claude, GPT, or Gemini) work on your codebase, they look for `.opencode` to understand:

- **Who they are** — agent definitions and roles
- **What to do** — commands and workflows
- **How to behave** — context files, standards, and conventions
- **What tools to use** — skills, plugins, and integrations

Think of `.opencode` as a **project-specific instruction manual** for AI agents.

### Why Use `.opencode`?

1. **Consistency** — Every AI interaction follows the same rules
2. **Context** — Agents understand your tech stack, architecture, and constraints
3. **Automation** — Commands and workflows run standardized tasks
4. **Collaboration** — Team members share the same AI configuration
5. **Portability** — Move your AI setup between projects easily

---

## Repository Structure

```
.
├── .opencode/               # AI agent configuration
│   ├── agent/              # Agent definitions
│   │   ├── core/           # Core agents (5 agents)
│   │   ├── subagents/      # Specialist subagents (24 agents)
│   │   ├── content/        # SEO & content agents (16 agents)
│   │   └── data/           # Data analyst agents (1 agent)
│   ├── command/            # CLI commands and scripts (14 files)
│   ├── context/            # Context files and standards (176 files)
│   │   ├── core/           # Core standards and workflows
│   │   ├── development/    # Development guidelines
│   │   ├── ui/             # UI/UX standards
│   │   ├── project/        # Project-specific context
│   │   ├── project-intelligence/  # Living documentation
│   │   └── openagents-repo/       # OpenAgents ecosystem docs
│   ├── skills/             # Reusable skill modules (7 files)
│   ├── config/             # Agent metadata and configuration
│   ├── tool/               # Utility tools
│   └── plugin/             # Plugin scripts
├── install.sh              # Installer script
├── AGENTS.md               # Project context for Hunivo
└── README.md               # This file
```

---

## Installation Profiles

Profiles let you install only the components you need. Each profile is a curated subset of the full repository.

### Profile Comparison

| Profile | Files | Agents | Contexts | Commands | Skills | Best For |
|---------|-------|--------|----------|----------|--------|----------|
| **minimal** | ~19 | 5 | 14 | 0 | 0 | Quick setup, CI/CD |
| **essential** | ~80 | 10 | 50+ | 14 | 0 | General development |
| **developer** | ~140 | 15+ | 100+ | 14 | 7 | Full-stack development |
| **content** | ~60 | 16 | 30+ | 0 | 0 | SEO & content teams |
| **full** | 244 | 42 | 176 | 14 | 7 | Everything |

### When to Use Each Profile

#### `minimal` — Core Agents Only

**What's included:**
- 5 core agents (code-reviewer, security-auditor, docs-writer, opencoder, openagent)
- Basic standards (code quality, security, documentation)
- Core context system files

**Use when:**
- Setting up a new project quickly
- CI/CD pipelines that need minimal agent support
- You want to start small and add more later

```bash
curl -fsSL ... | bash -s minimal
```

#### `essential` — Standard Development Setup

**What's included:**
- Everything from `minimal`
- Core subagents (contextscout, task-manager, documentation, externalscout)
- Code subagents (build-agent, coder-agent, reviewer, test-engineer)
- Development contexts (backend, frontend, fullstack)
- All CLI commands (commit, test, validate, optimize, etc.)

**Use when:**
- Starting a standard software project
- You need code review, testing, and validation tools
- Working with a team that follows standard conventions

```bash
curl -fsSL ... | bash -s essential
```

#### `developer` — Full Development Toolkit

**What's included:**
- Everything from `essential`
- Specialist subagents (frontend-expert, mobile-expert, performance-auditor, devops-specialist)
- System builder subagents (context-organizer)
- All context files (development, UI, infrastructure, AI frameworks)
- Skills (task-management, context7 library registry)
- Visual development workflows

**Use when:**
- Working on complex full-stack applications
- You need specialized agents for frontend, mobile, or performance
- Managing large codebases with multiple technologies

```bash
curl -fsSL ... | bash -s developer
```

#### `content` — SEO & Content Teams

**What's included:**
- 16 SEO & content agents (backlinks, clusters, schema, sitemap, local SEO, etc.)
- UI context files (web animations, design systems, React patterns)
- Core agents for content review

**Use when:**
- Working on content marketing or SEO
- Building websites with strong content requirements
- Managing multiple content projects

```bash
curl -fsSL ... | bash -s content
```

#### `full` — The Complete Package

**What's included:**
- All 244 files
- Every agent, subagent, context, command, skill, and tool
- Complete OpenAgents ecosystem documentation

**Use when:**
- You want everything available
- Working on the OpenAgents project itself
- You have a large team with diverse needs

```bash
curl -fsSL ... | bash -s full
```

---

## Installation Methods

### One-Liner (Non-Interactive)

The fastest way. Specify a profile and the installer runs automatically:

```bash
# Install full profile to default location (.opencode/)
curl -fsSL https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh | bash -s full

# Install developer profile
curl -fsSL https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh | bash -s developer

# Install essential profile to a custom directory
curl -fsSL https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh | bash -s essential --install-dir ~/my-agents
```

**Note:** In non-interactive mode, existing files are **skipped** (not overwritten). To force overwrite, delete the target directory first or run interactively.

### Interactive Mode

For more control, run the installer without a profile argument:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Treon-Studio/agents/main/install.sh)
```

You'll be guided through:

1. **Choose installation location**
   - **Local** — `.opencode/` in current directory (default)
   - **Global** — `~/.config/opencode/` (available everywhere)
   - **Custom** — Any path you specify

2. **Choose a profile**
   - Minimal, Essential, Developer, Content, or Full

3. **Review and confirm**
   - See exactly what will be installed
   - Choose to proceed or cancel

### Local Clone

Clone the repo and run locally (uses local files directly — no download):

```bash
git clone https://github.com/Treon-Studio/agents.git
cd agents
bash install.sh developer --install-dir ./my-opencode
```

This is useful for:
- Development and testing
- Air-gapped environments
- Modifying profiles before installation

### Update from Remote

Keep your `.opencode` installation in sync with the upstream repository:

```bash
# Update from default repository (Treon-Studio/agents)
bash install.sh --update

# Preview changes without applying
bash install.sh --update --dry-run

# Update with a custom source repository
bash install.sh --update --source https://github.com/owner/repo

# Update with automatic backup of overwritten files
bash install.sh --update --backup-dir ~/.opencode_backups
```

**How it works:**
1. Downloads latest archive from repository
2. Computes SHA256 checksums for both local and remote files
3. Compares and determines which files need updating
4. Shows change summary (files to update, add, or skip)
5. Applies changes with optional backup

**Options:**
| Option | Description |
|--------|-------------|
| `--update` | Run update mode |
| `--dry-run` | Preview changes without applying |
| `--source URL` | Use custom repository URL |
| `--backup-dir PATH` | Backup directory for overwritten files |

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `AGENTS_BRANCH` | `main` | Git branch to install from (useful for testing beta versions) |
| `AGENTS_INSTALL_DIR` | `.opencode` | Default installation directory |

**Examples:**

```bash
# Install from a specific branch
export AGENTS_BRANCH=develop
curl -fsSL ... | bash -s full

# Set default install location
export AGENTS_INSTALL_DIR=~/.config/opencode
curl -fsSL ... | bash -s essential
```

### Custom Installation Directory

Use `--install-dir` to specify where to install:

```bash
# Global installation (recommended for system-wide use)
curl -fsSL ... | bash -s full --install-dir ~/.config/opencode

# Project-specific installation
curl -fsSL ... | bash -s developer --install-dir ./my-project/.opencode

# Windows (Git Bash)
curl -fsSL ... | bash -s essential --install-dir /c/Users/YourName/opencode
```

---

## How It Works

The installer (`install.sh`) follows this process:

```
┌─────────────────┐
│  Parse args     │ ──→ Profile? Install dir?
└────────┬────────┘
         ▼
┌─────────────────┐
│ Check deps      │ ──→ Verify bash, curl, tar exist
└────────┬────────┘
         ▼
┌─────────────────┐
│ Get source      │ ──→ Local .opencode/ or download from GitHub
└────────┬────────┘
         ▼
┌─────────────────┐
│ Filter by       │ ──→ Apply profile patterns (minimal, developer, etc.)
│ profile         │
└────────┬────────┘
         ▼
┌─────────────────┐
│ Install files   │ ──→ Copy to target directory, skip existing
└────────┬────────┘
         ▼
┌─────────────────┐
│ Report results  │ ──→ Show installed / skipped / failed counts
└─────────────────┘
```

### Smart Behaviors

1. **Local-first** — If you run the installer from inside a cloned repo, it uses local `.opencode/` directly instead of downloading
2. **Skip existing** — Non-interactive mode skips existing files to prevent accidental overwrites
3. **Path normalization** — Handles `~` expansion, backslash conversion (Windows), and relative paths
4. **Profile filtering** — Only copies files matching the selected profile's patterns
5. **Validation** — Checks downloaded archives to ensure they're valid (not 404 HTML pages)

---

## What's Inside

### Agents

Agents are high-level AI personas with specific roles and responsibilities.

#### Core Agents (`agent/core/`)

| Agent | Purpose |
|-------|---------|
| `code-reviewer` | Reviews code for quality, security, and best practices |
| `security-auditor` | Scans for vulnerabilities and security issues |
| `docs-writer` | Generates and maintains documentation |
| `opencoder` | General-purpose coding assistant |
| `openagent` | Primary project agent with full context |

#### Subagents (`agent/subagents/`)

Specialist agents for specific domains:

**Code Specialists:**
- `build-agent` — Build and compilation expert
- `coder-agent` — Focused code generation
- `reviewer` — Detailed code review
- `test-engineer` — Test writing and validation

**Development Specialists:**
- `frontend-specialist` — React, CSS, UI implementation
- `devops-specialist` — CI/CD, infrastructure, deployment
- `performance-auditor` — Performance optimization

**System Builders:**
- `context-organizer` — Manages and structures context files

**Utils:**
- `image-specialist` — Image optimization and generation

#### Content Agents (`agent/content/`)

16 specialized SEO and content agents:

| Agent | Focus |
|-------|-------|
| `copywriter` | General content writing |
| `seo-backlinks` | Backlink analysis and strategy |
| `seo-cluster` | Content clustering |
| `seo-content` | Content quality audit |
| `seo-dataforseo` | DataForSEO integration |
| `seo-drift` | SEO monitoring and regression |
| `seo-ecommerce` | E-commerce SEO |
| `seo-geo` | Generative Engine Optimization (AI search) |
| `seo-google` | Google API integration |
| `seo-image-gen` | AI image generation for SEO |
| `seo-local` | Local SEO optimization |
| `seo-maps` | Maps and geo-grid intelligence |
| `seo-performance` | SEO performance audit |
| `seo-schema` | Schema.org structured data |
| `seo-sitemap` | XML sitemap analysis |
| `seo-sxo` | Search Experience Optimization |
| `seo-technical` | Technical SEO audit |
| `seo-visual` | Visual SEO optimization |
| `technical-writer` | Technical documentation |

### Context Files

Context files provide background knowledge and standards to AI agents. With **176 files**, they cover:

#### Core Context (`context/core/`)

- **Standards** — Code quality, security patterns, test coverage, documentation standards
- **System** — Context system guide, path management
- **Workflows** — Code review, feature breakdown, design iteration, session management
- **Task Management** — Task splitting, managing tasks, task schema
- **Visual Development** — Animation guides, design systems

#### Development Context (`context/development/`)

Domain-specific guidelines for:

| Domain | Contents |
|--------|----------|
| Backend | API design, database patterns, server architecture |
| Frontend (Web) | React patterns, animation, design systems |
| Frontend (Mobile) | React Native, mobile-specific patterns |
| Fullstack | Integration patterns, end-to-end workflows |
| AI Frameworks | Mastra AI concepts, agents, tools, workflows |
| Infrastructure | DevOps, deployment, CI/CD |
| Data | Data modeling, migration, management |

#### Project Intelligence (`context/project-intelligence/`)

Living documentation that evolves with your project:

- `business-domain.md` — Business logic and domain rules
- `technical-domain.md` — Technical architecture and decisions
- `business-tech-bridge.md` — How business maps to technology
- `decisions-log.md` — Architecture Decision Records (ADRs)
- `living-notes.md` — Ongoing observations and learnings

#### OpenAgents Repo Context (`context/openagents-repo/`)

Documentation for contributing to the OpenAgents ecosystem:

- **Guides** — Adding agents, skills, testing subagents
- **Core Concepts** — Agent metadata, registry, categories
- **Examples** — Context bundles, subagent prompts
- **Blueprints** — Templates for new components

### Commands

CLI commands that AI agents can execute:

| Command | Purpose |
|---------|---------|
| `add-context` | Add context files to a session |
| `analyze-patterns` | Analyze codebase patterns |
| `check` | Check context dependencies |
| `clean` | Clean up generated files |
| `commit` | AI-assisted commit message generation |
| `context` | Manage context files |
| `format-edits` | Format code edits consistently |
| `optimize` | Optimize code or configuration |
| `test` | Run tests with AI interpretation |
| `validate-repo` | Validate repository structure |
| `worktrees` | Manage Git worktrees |

### Skills

Reusable skill modules that agents can invoke:

| Skill | Purpose |
|-------|---------|
| `task-management` | Task routing, CLI scripts for task operations |
| `context7` | Library registry for Context7 integration |

### Tools & Plugins

| Component | Purpose |
|-----------|---------|
| `tool/env` | Environment variable management |
| `tool/gemini` | Google Gemini integration |
| `plugin/notify` | Notification system |

---

## Project Context (AGENTS.md)

This repository includes `AGENTS.md` — a **project-specific context file** for the [Hunivo](https://github.com/Treon-Studio) property management SaaS.

### What AGENTS.md Contains

```
Hunivo — Indonesian Property Management SaaS
├── Tech Stack
│   ├── API: Hono, Cloudflare Workers, D1 (SQLite), Drizzle ORM
│   ├── Web: Astro 5 (SSR), React 19, TailwindCSS 4
│   ├── Mobile: Expo 54, React Native 0.81, HeroUI Native
│   ├── State: Zustand 5 (client), React Query 5 (server)
│   └── Auth: JWT (HS256), RBAC with 4 roles
├── Project Structure
│   ├── apps/ (api, web, app)
│   ├── packages/ (api-types, api-services, api-hooks, etc.)
│   └── platforms/ (auth, house-rent, notifications, etc.)
├── Critical Conventions
│   ├── DO: Use @treonstudio/* imports, SQL arithmetic, generateId()
│   └── DON'T: Use uuid, skip workspace scoping, hardcode config
├── Database Rules
│   ├── IDs: Always cuid2 via generateId()
│   ├── Workspace scoping: EVERY query filters by workspaceId
│   └── Counter updates: SQL arithmetic only
└── Business Constraints
    ├── billingDay: 1-28 only
    ├── Cannot delete property with occupied rooms
    └── Lease lifecycle rules
```

When AI agents work on the Hunivo project, they read `AGENTS.md` first to understand the codebase conventions, preventing common mistakes and ensuring consistency.

---

## Requirements

- **Bash** 3.2 or higher
- **curl** — for downloading
- **tar** — for extracting archives

### Platform Support

| Platform | Compatibility | Notes |
|----------|---------------|-------|
| macOS | ✅ Full | Tested on bash 3.2+ and zsh |
| Linux | ✅ Full | Tested on Ubuntu, Debian, Fedora |
| Windows Git Bash | ✅ Full | Install Git for Windows |
| Windows WSL | ✅ Full | WSL1 and WSL2 |
| Windows CMD/PowerShell | ❌ Not supported | Use Git Bash or WSL |

### Checking Your Environment

```bash
# Check bash version
bash --version

# Check if curl is installed
which curl

# Check if tar is installed
which tar
```

---

## Troubleshooting

### "Downloaded file is not a valid archive"

**Cause:** The GitHub repository might be empty, private, or the branch doesn't exist.

**Solution:**
```bash
# Verify the repository exists and is public
open https://github.com/Treon-Studio/agents

# Try a specific branch
export AGENTS_BRANCH=main
curl -fsSL ... | bash -s full
```

### "curl is required but not installed"

**macOS:**
```bash
brew install curl
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt-get install curl tar
```

**Linux (Fedora):**
```bash
sudo dnf install curl tar
```

### "Permission denied" when installing

**Solution:** Ensure you have write permission to the target directory:
```bash
# Check permissions
ls -la $(dirname ~/my-target)

# Or install to a directory you own
curl -fsSL ... | bash -s full --install-dir ~/my-opencode
```

### Existing files not being overwritten

**Cause:** The installer skips existing files in non-interactive mode by design.

**Solution:**
```bash
# Option 1: Delete existing files first
rm -rf .opencode
curl -fsSL ... | bash -s full

# Option 2: Run interactively to choose overwrite
bash <(curl -fsSL ...)

# Option 3: Install to a different directory
curl -fsSL ... | bash -s full --install-dir ./fresh-opencode
```

### Running from a cloned repo still downloads

**Cause:** The installer only uses local files if `.opencode/config/agent-metadata.json` exists in the current directory.

**Solution:**
```bash
cd agents  # Make sure you're in the repo root
bash install.sh full
```

---

## Contributing

We welcome contributions! Here's how to get started:

### 1. Fork and Clone

```bash
git clone https://github.com/your-username/agents.git
cd agents
```

### 2. Make Changes

- **Add a new agent** → Create a `.md` file in `.opencode/agent/`
- **Add context** → Create files in `.opencode/context/`
- **Add a command** → Create files in `.opencode/command/`
- **Update profiles** → Modify `get_profile_patterns()` in `install.sh`

### 3. Test Locally

```bash
# Test full installation
bash install.sh full --install-dir /tmp/test-full

# Test specific profile
bash install.sh developer --install-dir /tmp/test-dev

# Test minimal profile
bash install.sh minimal --install-dir /tmp/test-min
```

### 4. Verify File Counts

```bash
# Count installed files
find /tmp/test-dev -type f | wc -l

# List installed agents
find /tmp/test-dev/agent -type f

# Check contexts
find /tmp/test-dev/context -type f | head -20
```

### 5. Submit a Pull Request

- Describe what you added and why
- Include test results (file counts, etc.)
- Follow existing naming conventions

### Contribution Guidelines

- **Agents:** Use lowercase with hyphens (`my-new-agent.md`)
- **Context:** Organize by domain (`context/development/backend.md`)
- **Commands:** Include a header comment explaining usage
- **Skills:** Provide a `SKILL.md` with usage instructions

---

## FAQ

### What's the difference between agents and subagents?

**Agents** are top-level personas that handle general tasks. **Subagents** are specialists that agents delegate to for specific domains (e.g., a frontend specialist for React components).

### Can I use multiple profiles?

Not directly — each installation replaces the previous one for overlapping files. Install the `full` profile if you need everything, or manually merge profiles by running the installer multiple times with different directories.

### How do I update my installation?

Re-run the installer with the same profile:
```bash
curl -fsSL ... | bash -s full
```

Existing files will be skipped, new files will be added. To force a complete refresh, delete `.opencode/` first.

### Can I install this in a monorepo?

Yes! Install `.opencode` at the repository root. The context system supports monorepos through path configuration.

### What if I only need one agent?

Currently, profiles are the smallest installable unit. For a single agent, install the relevant profile and delete unwanted files, or copy the agent file manually from the repository.

### Is this tied to a specific AI model?

No. The `.opencode` convention is model-agnostic. It works with Claude, GPT-4, Gemini, and any AI assistant that reads project files.

### How does this compare to `.cursorrules` or `.claude`?

`.opencode` is inspired by these conventions but goes further:
- **Structured** — Organized into agents, commands, skills, context
- **Modular** — Install only what you need
- **Extensible** — Easy to add new agents and workflows
- **Standardized** — Works across different AI platforms

---

## License

MIT © [Treon Studio](https://github.com/Treon-Studio)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
