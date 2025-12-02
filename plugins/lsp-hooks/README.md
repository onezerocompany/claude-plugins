# LSP Hooks Plugin

A powerful plugin that integrates Language Server Protocol (LSP) capabilities into Claude Code through automated hooks, providing real-time code diagnostics, formatting validation, and language intelligence.

## What does it do?

This plugin adds LSP integration to Claude Code with automatic dependency management and multi-language support. It provides:

- **Automatic LSP installation**: Downloads and configures language servers on-demand
- **Real-time diagnostics**: Checks code for errors and warnings after file modifications
- **Format validation**: Validates code formatting before writing changes
- **Multi-language support**: 15+ programming languages including TypeScript, Python, Go, Rust, and more
- **Workspace monitoring**: Tracks project health and LSP server status
- **MCP integration**: Uses Model Context Protocol for seamless Claude integration

## Installation

From the claude-plugins marketplace:

```bash
/plugin install lsp-hooks@claude-plugins
```

## Supported Languages

### JavaScript/TypeScript
- typescript-language-server, Deno, ESLint
- Formatters: Prettier, Biome

### Backend Languages
- **Go**: gopls, gofmt
- **Python**: pyright, black, ruff
- **Ruby**: solargraph
- **Java**: jdtls
- **Elixir**: elixir-ls
- **C#**: omnisharp
- **Lua**: lua-language-server

### Systems Languages
- **Rust**: rust-analyzer, rustfmt
- **C/C++**: clangd, clang-format
- **Zig**: zls
- **Swift**: sourcekit-lsp

### Modern Frameworks
- **Vue**: vue-language-server
- **Svelte**: svelteserver
- **Astro**: astro-ls

## How It Works

### Automatic Setup

On first use, the plugin automatically:

1. Detects your system capabilities (Go, Node.js, etc.)
2. Downloads and installs `mcp-language-server` (if Go is available)
3. Installs language servers for detected project types
4. Configures LSP hooks for your workspace

All installations happen in `.deps/` within the plugin directory and don't affect your system.

### Hook Events

The plugin registers hooks that automatically run during your coding session:

#### SessionStart Hook
- Installs dependencies on first run
- Detects project type (TypeScript, Go, Rust, Python, etc.)
- Identifies available language servers
- Creates workspace configuration

#### PreToolUse Hook (Write/Edit)
- Validates code formatting before changes
- Checks with appropriate formatters (prettier, black, rustfmt, etc.)
- Warns if formatting issues are detected
- Always allows operation (non-blocking)

#### PostToolUse Hook (Write/Edit)
- Queries LSP server for diagnostics after file modifications
- Reports errors, warnings, and hints
- Provides feedback on code quality
- Integrates with language server capabilities

#### UserPromptSubmit Hook
- Monitors workspace health on prompt submission
- Checks LSP server status
- Tracks code quality metrics

## Commands

### Check LSP Diagnostics

```bash
/lsp-check
```

Runs LSP diagnostics on the current file or project and reports all findings.

### Format Code

```bash
/lsp-format
```

Formats code using available language server formatters and ensures proper formatting.

## Configuration

### Supported Language Servers

The plugin automatically configures language servers based on file extensions and project indicators:

- **TypeScript/JavaScript**: Looks for `package.json`, `tsconfig.json`
- **Go**: Looks for `go.mod`, `go.sum`
- **Rust**: Looks for `Cargo.toml`, `Cargo.lock`
- **Python**: Looks for `pyproject.toml`, `setup.py`, `requirements.txt`

### Custom Configuration

Language server settings are defined in `scripts/lsp-config.json`. You can customize:

- Command paths
- Arguments
- File extensions
- Root indicators
- Enable/disable specific servers

## Dependencies

### Automatic Installation

The plugin handles dependency installation automatically. It will install:

- **mcp-language-server**: MCP-based LSP client (requires Go)
- **lsp-cli**: Fallback LSP client (if Go unavailable)
- **Language servers**: Based on detected project types

### Manual Installation

If you prefer manual control, install tools globally:

```bash
# Install Go (for mcp-language-server)
brew install go  # macOS
# or download from https://go.dev/dl/

# Install language servers
npm install -g typescript-language-server typescript
pip install pyright
go install golang.org/x/tools/gopls@latest
rustup component add rust-analyzer
```

## Architecture

### Directory Structure

```
lsp-hooks/
├── plugin.json                    # Plugin manifest
├── hooks/
│   └── hooks.json                 # Hook configuration
├── scripts/
│   ├── install-dependencies.sh    # Auto-installer
│   ├── init-lsp.sh               # Session initialization
│   ├── check-diagnostics.sh      # Diagnostic checking
│   ├── validate-format.sh        # Format validation
│   ├── check-workspace-health.sh # Workspace monitoring
│   ├── get-lsp-command.sh        # Command resolver
│   └── lsp-config.json           # Language server config
└── .deps/                         # Dependencies (auto-created)
    ├── bin/                       # Binaries
    ├── node_modules/              # Node.js packages
    └── .initialized               # Installation state
```

### Integration Approach

This plugin uses the same foundation as [OpenCode](https://opencode.ai):

- **mcp-language-server**: Bridges LSP servers with Model Context Protocol
- **Automatic detection**: File extension-based language server selection
- **Hook-based automation**: Runs checks transparently during coding
- **Non-blocking**: Never interrupts your workflow

## Best Used For

- Real-time code quality feedback
- Catching errors before commits
- Ensuring consistent formatting
- Multi-language project development
- Learning language-specific best practices
- CI/CD pre-checks

## Limitations

- First-time setup requires internet connection
- Some language servers require their runtimes (Go for gopls, Node.js for typescript-language-server)
- Diagnostic accuracy depends on language server capabilities
- Hook execution adds minimal overhead to file operations

## Troubleshooting

### Dependencies not installing

Check the installation log:

```bash
cat ~/.claude/plugins/lsp-hooks/.deps/install.log
```

Ensure you have:
- Internet connection
- Go installed (for mcp-language-server)
- Sufficient disk space

### Language server not found

The plugin auto-detects but you can manually install:

```bash
# TypeScript
npm install -g typescript-language-server typescript

# Python
pip install pyright

# Go
go install golang.org/x/tools/gopls@latest
```

### Hooks not running

Verify hooks are enabled in your Claude Code settings and check:

```bash
/hooks
```

## Performance

- **Minimal overhead**: Hooks run asynchronously
- **Smart caching**: Language servers persist across sessions
- **Background installation**: Dependencies install without blocking
- **Selective activation**: Only runs for supported file types

## Contributing

Contributions welcome! Add support for more languages or improve existing integrations:

https://github.com/OneZeroCompany/claude-plugins

## Credits

Built on:
- [mcp-language-server](https://github.com/isaacphi/mcp-language-server) by @isaacphi
- [lsp-cli](https://github.com/valentjn/lsp-cli) by @valentjn
- Inspired by [OpenCode](https://opencode.ai) LSP implementation

## License

MIT License - see the root repository for full license details.
