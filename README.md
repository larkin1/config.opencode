# OpenCode Configuration

Configuration files for the OpenCode AI agent.

## Setup

```bash
bash setup.sh
```

Idempotent — safe to re-run. Installs dependencies, sets up the caveman submodule, and symlinks skills.

## Plugins

Loaded from npm at startup (auto-fetched by opencode).

| Plugin | Purpose |
|--------|---------|
| `@tarquinen/opencode-dcp` | Dynamic Context Pruning — compresses conversation context to optimize performance |
| `opencode-handoff` | Session handoff — save/resume state across conversations via `/handoff` |

## Skills

Sourced from [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) via git submodule.

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `caveman` | `/caveman [lite\|full\|ultra\|wenyan-*]` | Ultra-compressed communication, ~75% token reduction |
| `caveman-commit` | `/caveman-commit` | Terse conventional commit messages |
| `caveman-review` | `/caveman-review` | One-line code review comments |

To update: `git submodule update --remote vendor/caveman`

## Dependencies

| Package | Purpose |
|---------|---------|
| `@opencode-ai/plugin` | Core OpenCode plugin SDK |

Managed by opencode — auto-installed via `bun install` at startup.

## Structure

```
~/.config/opencode/
  opencode.json         Main opencode config (plugins, permissions, agents)
  dcp.jsonc             DCP configuration
  package.json          Local plugin dependencies (auto-managed by opencode)
  setup.sh              Repo setup script
  skills/               Symlinked skill directories
  vendor/caveman/       Git submodule — caveman skill sources
```
