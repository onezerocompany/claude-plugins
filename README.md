# Claude Plugins Marketplace

This is a **plugin marketplace** for [Claude Code](https://claude.ai/download).

A plugin marketplace is a catalog that distributes Claude Code plugins. It contains:
- A [`marketplace.json`](.claude-plugin/marketplace.json) registry listing available plugins
- Plugin source directories in [`plugins/`](plugins/)

That's it. This repo is not a CLI tool, not a plugin framework, and not documentation for Claude Code.

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [commit-authoring](plugins/commit-authoring) | AI-powered git commit message generation and staging management |
| [claude-workflows](plugins/claude-workflows) | Expert guidance for creating GitHub workflows with Claude Code Action |
| [starlight-docs](plugins/starlight-docs) | Documentation site scaffolding with Starlight |

## Installation

Add this marketplace to Claude Code:

```
/plugin marketplace add github:onezerocompany/claude-plugins
```

Install a plugin:

```
/plugin install commit-authoring@onezero-plugins
```

## Contributing

To add a plugin to this marketplace:

1. Fork this repository
2. Add your plugin to `plugins/your-plugin-name/`
3. Add an entry to `.claude-plugin/marketplace.json`
4. Submit a pull request

For how to create plugins, see the [official Claude Code plugin documentation](https://claude.ai/download).

## License

MIT
