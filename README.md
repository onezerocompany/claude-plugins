# Claude Plugins Marketplace

A curated marketplace of Claude Code plugins for enhanced productivity and functionality.

## What is this?

This repository serves as a plugin marketplace for [Claude Code](https://code.claude.com/), Anthropic's official CLI tool. It provides a centralized location to discover, install, and manage plugins that extend Claude's capabilities.

## Available Plugins

Browse available plugins in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json) or explore the [`plugins/`](plugins/) directory.

### Featured Plugins

- **hello-world** - A simple example plugin demonstrating basic command structure
- **code-reviewer** - An agent plugin that provides automated code review capabilities

## Installation

### Add this marketplace to Claude Code

```bash
/plugin marketplace add github:OneZeroCompany/claude-plugins
```

Or if using the repository URL directly:

```bash
/plugin marketplace add https://github.com/OneZeroCompany/claude-plugins.git
```

### Install a plugin

Once you've added the marketplace, install any plugin:

```bash
/plugin install hello-world@claude-plugins
/plugin install code-reviewer@claude-plugins
```

### List available plugins

```bash
/plugin marketplace list claude-plugins
```

## For Teams

Organizations can automatically include this marketplace for all team members by adding it to `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": [
    {
      "source": "github",
      "repo": "OneZeroCompany/claude-plugins"
    }
  ]
}
```

Team members will see these plugins available when they trust the repository.

## Contributing a Plugin

We welcome community contributions! To add your plugin to this marketplace:

### Option 1: Host your plugin in this repository

1. Fork this repository
2. Create a new directory under `plugins/` with your plugin name
3. Add your plugin files including `plugin.json` manifest
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

- **plugin.json** - A valid plugin manifest with required fields (name, version, description)
- **README.md** - Documentation explaining what the plugin does and how to use it
- Clear licensing information
- Proper error handling and validation

See our [example plugins](plugins/) for reference.

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

### Testing locally

You can test the marketplace locally before publishing:

```bash
/plugin marketplace add file:///path/to/claude-plugins
```

## Plugin Structure

A basic plugin manifest (`plugin.json`) looks like:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What this plugin does",
  "author": {
    "name": "Your Name",
    "email": "your@email.com"
  },
  "commands": [
    {
      "name": "my-command",
      "description": "Command description",
      "file": "./commands/my-command.js"
    }
  ]
}
```

For more details, see the [Claude Code Plugin Documentation](https://code.claude.com/docs/en/plugins).

## License

This marketplace is licensed under the MIT License. Individual plugins may have their own licenses - please check each plugin's documentation.

## Support

- **Issues**: [GitHub Issues](https://github.com/OneZeroCompany/claude-plugins/issues)
- **Documentation**: [Claude Code Docs](https://code.claude.com/docs)
- **Community**: Join discussions in our repository

---

Made with ❤️ by OneZero Company
