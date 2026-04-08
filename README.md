# OpenCode Configuration

Configuration files for the OpenCode AI agent.

## Plugins

| Plugin | Purpose |
|--------|---------|
| `@tarquinen/opencode-dcp` | Dynamic Context Pruning (DCP) - manages conversation context window to optimize performance |
| `opencode-handoff` | Handoff extension - enables session state saving and resuming across conversations |

## Dependencies

| Package | Purpose |
|---------|---------|
| `@opencode-ai/plugin` | Core OpenCode plugin SDK |

## Files

- `opencode.json` - Main OpenCode configuration file
- `dcp.jsonc` - DCP (Dynamic Context Pruning) configuration
