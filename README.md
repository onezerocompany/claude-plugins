# Claude Plugins Marketplace

A curated marketplace of Claude Code plugins for enhanced productivity and functionality.

## What is this?

This repository serves as a plugin marketplace for [Claude Code](https://code.claude.com/), Anthropic's official CLI tool. It provides a centralized location to discover, install, and manage plugins that extend Claude's capabilities.

## Available Plugins

Browse available plugins in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) or explore the [`plugins/`](plugins/) directory.

### Featured Plugins

| Plugin | Description |
|--------|-------------|
| **[claude-workflows](plugins/claude-workflows)** | Expert guidance for creating secure GitHub workflows using Claude Code Action |
| **[commit-authoring](plugins/commit-authoring)** | Intelligent git commit authoring with AI-powered message generation |
| **[lsp-hooks](plugins/lsp-hooks)** | LSP integration for automated diagnostics, formatting, and validation |

## Installation

### Add this marketplace to Claude Code

```bash
/install-plugin github:OneZeroCompany/claude-plugins/<plugin-name>
```

For example:

```bash
/install-plugin github:OneZeroCompany/claude-plugins/commit-authoring
/install-plugin github:OneZeroCompany/claude-plugins/lsp-hooks
```

## Contributing a Plugin

We welcome community contributions! To add your plugin to this marketplace:

### Option 1: Host your plugin in this repository

1. Fork this repository
2. Create a new directory under `plugins/` with your plugin name
3. Add your plugin files including `.claude-plugin/plugin.json` manifest
4. Update `.claude-plugin/marketplace.json` to include your plugin entry
5. Submit a pull request

### Option 2: Reference an external plugin

1. Fork this repository
2. Update `.claude-plugin/marketplace.json` to add your plugin entry with a GitHub or git source:
   ```json
   {
     "name": "your-plugin",
     "description": "Your plugin description",
     "version": "1.0.0",
     "source": {
       "source": "github",
       "repo": "your-username/your-plugin-repo"
     }
   }
   ```
3. Submit a pull request

### Plugin Requirements

All plugins must include:

- **`.claude-plugin/plugin.json`** - A valid manifest with required fields (name, version, description)
- **`README.md`** - Documentation explaining what the plugin does and how to use it
- **`LICENSE`** - Clear licensing information
- At least one component (commands, agents, skills, or hooks)

See our [existing plugins](plugins/) for reference.

## Development

### Prerequisites

This project uses [mise](https://mise.jdx.dev/) for tool version management and [Bun](https://bun.sh/) as the JavaScript runtime.

#### Install mise

```bash
# macOS/Linux
curl https://mise.run | sh

# Or with Homebrew
brew install mise
```

#### Install tools

```bash
# Install Bun via mise (configured in .mise.toml)
mise install

# Or install Bun directly
curl -fsSL https://bun.sh/install | bash
```

### Validate the marketplace

```bash
bun run validate
```

This checks that:
- `marketplace.json` is valid JSON
- All plugin entries have required fields
- Referenced local plugins exist

### Lint plugins

```bash
bun run lint
```

This validates:
- Plugin manifests have required fields
- Plugin structure follows best practices
- READMEs are present

### Run all checks

```bash
bun run check
```

Runs both validation and linting.

## Plugin Structure

A plugin directory should contain:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json      # Plugin manifest (required)
├── commands/            # Slash commands (optional)
├── agents/              # Autonomous agents (optional)
├── skills/              # Skills for context (optional)
├── hooks/               # Event hooks (optional)
├── LICENSE              # License file
└── README.md            # Documentation
```

The manifest (`.claude-plugin/plugin.json`) looks like:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What this plugin does",
  "author": {
    "name": "Your Name",
    "email": "your@email.com"
  },
  "license": "MIT",
  "commands": ["./commands/my-command.md"],
  "agents": ["./agents/my-agent.md"],
  "skills": ["./skills/my-skill.md"]
}
```

For more details, see the [Claude Code Plugin Documentation](https://docs.anthropic.com/en/docs/claude-code/plugins).

## License

This marketplace is licensed under the MIT License. Individual plugins may have their own licenses - please check each plugin's documentation.

## Support

- **Issues**: [GitHub Issues](https://github.com/OneZeroCompany/claude-plugins/issues)
- **Documentation**: [Claude Code Docs](https://code.claude.com/docs)
- **Community**: Join discussions in our repository

---

Made with ❤️ by OneZero Company
