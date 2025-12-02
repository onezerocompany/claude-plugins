#!/usr/bin/env bash
# Initialize LSP connection and gather workspace diagnostics

set -euo pipefail

# Always get script directory for script references
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Use CLAUDE_PLUGIN_ROOT if available, otherwise derive from script location
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
  export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
fi

DEPS_DIR="$PLUGIN_ROOT/.deps"
STATE_FILE="$DEPS_DIR/.initialized"

echo "LSP Hooks Plugin: Initializing..."

# Install dependencies if not already installed
if [ ! -f "$STATE_FILE" ]; then
  echo "First run detected, installing dependencies..."
  "$SCRIPT_DIR/install-dependencies.sh" > "$DEPS_DIR/install.log" 2>&1 &
  INSTALL_PID=$!

  # Don't wait for installation to complete, mark as in-progress
  mkdir -p "$DEPS_DIR"
  echo "installing" > "$STATE_FILE"

  echo "Dependencies are being installed in the background (PID: $INSTALL_PID)"
  echo "Check $DEPS_DIR/install.log for progress"
else
  INSTALL_STATUS=$(cat "$STATE_FILE")
  if [ "$INSTALL_STATUS" = "installing" ]; then
    echo "Dependencies installation is still in progress"
  else
    echo "Dependencies already installed"
  fi
fi

# Detect project type and available language servers
PROJECT_TYPE="unknown"
AVAILABLE_SERVERS=()

if [ -f "package.json" ] || [ -f "tsconfig.json" ]; then
  PROJECT_TYPE="typescript"
  if [ -f "$DEPS_DIR/node_modules/.bin/typescript-language-server" ] || command -v typescript-language-server >/dev/null 2>&1; then
    AVAILABLE_SERVERS+=("typescript-language-server")
  fi
fi

if [ -f "go.mod" ]; then
  PROJECT_TYPE="go"
  if [ -f "$DEPS_DIR/bin/gopls" ] || command -v gopls >/dev/null 2>&1; then
    AVAILABLE_SERVERS+=("gopls")
  fi
fi

if [ -f "Cargo.toml" ]; then
  PROJECT_TYPE="rust"
  if [ -f "$DEPS_DIR/bin/rust-analyzer" ] || command -v rust-analyzer >/dev/null 2>&1; then
    AVAILABLE_SERVERS+=("rust-analyzer")
  fi
fi

if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
  PROJECT_TYPE="python"
  if [ -f "$DEPS_DIR/node_modules/.bin/pyright" ] || command -v pyright >/dev/null 2>&1; then
    AVAILABLE_SERVERS+=("pyright")
  fi
fi

# Save configuration for other scripts
cat > "$DEPS_DIR/.lsp-config.json" <<EOF
{
  "project_type": "$PROJECT_TYPE",
  "workspace": "$(pwd)",
  "available_servers": $(printf '%s\n' "${AVAILABLE_SERVERS[@]}" | jq -R . | jq -s .),
  "deps_dir": "$DEPS_DIR",
  "initialized_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "Detected project type: $PROJECT_TYPE"
echo "Available language servers: ${AVAILABLE_SERVERS[*]:-none}"

cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "LSP initialized. Project type: $PROJECT_TYPE. Available servers: ${AVAILABLE_SERVERS[*]:-none}"
}
EOF

exit 0
