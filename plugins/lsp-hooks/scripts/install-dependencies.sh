#!/usr/bin/env bash
# Install LSP dependencies on-demand

set -euo pipefail

# Use CLAUDE_PLUGIN_ROOT if available, otherwise derive from script location
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
fi

DEPS_DIR="$PLUGIN_ROOT/.deps"
LSP_CLI_VERSION="0.8.0"

mkdir -p "$DEPS_DIR"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install lsp-cli
install_lsp_cli() {
  if [ -f "$DEPS_DIR/lsp-cli/bin/lsp-cli" ]; then
    echo "lsp-cli already installed"
    return 0
  fi

  echo "Installing lsp-cli..."

  # Detect platform
  case "$(uname -s)" in
    Darwin*)
      PLATFORM="mac"
      ;;
    Linux*)
      PLATFORM="linux"
      ;;
    MINGW*|MSYS*|CYGWIN*)
      PLATFORM="windows"
      ;;
    *)
      echo "Unsupported platform: $(uname -s)"
      return 1
      ;;
  esac

  # Download and extract lsp-cli
  URL="https://github.com/valentjn/lsp-cli/releases/download/${LSP_CLI_VERSION}/lsp-cli-${LSP_CLI_VERSION}-${PLATFORM}.tar.gz"

  curl -L "$URL" -o "$DEPS_DIR/lsp-cli.tar.gz"
  tar -xzf "$DEPS_DIR/lsp-cli.tar.gz" -C "$DEPS_DIR"
  rm "$DEPS_DIR/lsp-cli.tar.gz"

  # Make executable
  chmod +x "$DEPS_DIR/lsp-cli-${LSP_CLI_VERSION}/bin/lsp-cli"

  # Create symlink
  ln -sf "$DEPS_DIR/lsp-cli-${LSP_CLI_VERSION}" "$DEPS_DIR/lsp-cli"

  echo "lsp-cli installed successfully"
}

# Function to install typescript-language-server
install_typescript_ls() {
  if [ -f "$DEPS_DIR/node_modules/.bin/typescript-language-server" ]; then
    echo "typescript-language-server already installed"
    return 0
  fi

  if ! command_exists npm && ! command_exists pnpm && ! command_exists bun; then
    echo "No Node.js package manager found. Skipping typescript-language-server installation."
    return 1
  fi

  echo "Installing typescript-language-server..."

  cd "$DEPS_DIR"

  # Use pnpm if available, otherwise npm, otherwise bun
  if command_exists pnpm; then
    pnpm init -y 2>/dev/null || true
    pnpm add typescript-language-server typescript
  elif command_exists bun; then
    bun init -y 2>/dev/null || true
    bun add typescript-language-server typescript
  else
    npm init -y 2>/dev/null || true
    npm install typescript-language-server typescript
  fi

  echo "typescript-language-server installed successfully"
}

# Function to install gopls (Go language server)
install_gopls() {
  if command_exists gopls; then
    echo "gopls already installed globally"
    return 0
  fi

  if [ -f "$DEPS_DIR/bin/gopls" ]; then
    echo "gopls already installed locally"
    return 0
  fi

  if ! command_exists go; then
    echo "Go not found. Skipping gopls installation."
    return 1
  fi

  echo "Installing gopls..."

  mkdir -p "$DEPS_DIR/bin"
  GOBIN="$DEPS_DIR/bin" go install golang.org/x/tools/gopls@latest

  echo "gopls installed successfully"
}

# Function to install rust-analyzer
install_rust_analyzer() {
  if command_exists rust-analyzer; then
    echo "rust-analyzer already installed globally"
    return 0
  fi

  if [ -f "$DEPS_DIR/bin/rust-analyzer" ]; then
    echo "rust-analyzer already installed locally"
    return 0
  fi

  if ! command_exists rustup; then
    echo "rustup not found. Skipping rust-analyzer installation."
    return 1
  fi

  echo "Installing rust-analyzer..."

  mkdir -p "$DEPS_DIR/bin"
  rustup component add rust-analyzer 2>/dev/null || true

  # If rustup installation doesn't work, try downloading binary
  if ! command_exists rust-analyzer; then
    case "$(uname -s)" in
      Darwin*)
        URL="https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-aarch64-apple-darwin.gz"
        if [ "$(uname -m)" = "x86_64" ]; then
          URL="https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-apple-darwin.gz"
        fi
        ;;
      Linux*)
        URL="https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz"
        ;;
      *)
        echo "Unsupported platform for rust-analyzer download"
        return 1
        ;;
    esac

    curl -L "$URL" -o "$DEPS_DIR/bin/rust-analyzer.gz"
    gunzip "$DEPS_DIR/bin/rust-analyzer.gz"
    chmod +x "$DEPS_DIR/bin/rust-analyzer"
  fi

  echo "rust-analyzer installed successfully"
}

# Function to install pyright (Python language server)
install_pyright() {
  if [ -f "$DEPS_DIR/node_modules/.bin/pyright" ]; then
    echo "pyright already installed"
    return 0
  fi

  if ! command_exists npm && ! command_exists pnpm && ! command_exists bun; then
    echo "No Node.js package manager found. Skipping pyright installation."
    return 1
  fi

  echo "Installing pyright..."

  cd "$DEPS_DIR"

  if command_exists pnpm; then
    pnpm init -y 2>/dev/null || true
    pnpm add pyright
  elif command_exists bun; then
    bun init -y 2>/dev/null || true
    bun add pyright
  else
    npm init -y 2>/dev/null || true
    npm install pyright
  fi

  echo "pyright installed successfully"
}

# Function to install mcp-language-server
install_mcp_language_server() {
  if [ -f "$DEPS_DIR/bin/mcp-language-server" ]; then
    echo "mcp-language-server already installed"
    return 0
  fi

  if ! command_exists go; then
    echo "Go not found. Skipping mcp-language-server installation."
    echo "Install Go from: https://go.dev/dl/"
    return 1
  fi

  echo "Installing mcp-language-server..."

  mkdir -p "$DEPS_DIR/bin"
  GOBIN="$DEPS_DIR/bin" go install github.com/isaacphi/mcp-language-server@latest

  echo "mcp-language-server installed successfully"
}

# Main installation
echo "Checking and installing LSP dependencies..."

# Install mcp-language-server as our primary MCP-based LSP interface
install_mcp_language_server || echo "Warning: mcp-language-server installation failed, falling back to lsp-cli"

# Fallback: install lsp-cli if mcp-language-server isn't available
if [ ! -f "$DEPS_DIR/bin/mcp-language-server" ]; then
  install_lsp_cli
fi

# Install language servers based on what's available
install_typescript_ls || true
install_gopls || true
install_rust_analyzer || true
install_pyright || true

# Mark installation as complete
echo "complete" > "$DEPS_DIR/.initialized"

echo "Dependency installation complete"
echo "Installed tools are available in: $DEPS_DIR"

exit 0
