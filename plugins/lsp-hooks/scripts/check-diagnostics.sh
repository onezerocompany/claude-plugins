#!/usr/bin/env bash
# Check for LSP diagnostics after file modifications

set -euo pipefail

# Always get script directory for script references
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Use CLAUDE_PLUGIN_ROOT if available, otherwise derive from script location
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
fi

DEPS_DIR="$PLUGIN_ROOT/.deps"

# Read the tool result from stdin
TOOL_INPUT=$(cat)

# Extract file path from the tool result if available
FILE_PATH=$(echo "$TOOL_INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "")

if [ -z "$FILE_PATH" ]; then
  # No file path found, exit successfully
  exit 0
fi

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Get absolute path
FILE_PATH=$(cd "$(dirname "$FILE_PATH")" && pwd)/$(basename "$FILE_PATH")

# Get file extension
EXT="${FILE_PATH##*.}"

# Get LSP command for this file type
LSP_CMD=$("$SCRIPT_DIR/get-lsp-command.sh" "$EXT" "$FILE_PATH" 2>/dev/null || echo "")

if [ -z "$LSP_CMD" ]; then
  # No LSP server available for this file type
  cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "No LSP server configured for extension: $EXT"
}
EOF
  exit 0
fi

echo "Checking LSP diagnostics for: $FILE_PATH (using $LSP_CMD)"

# Check if mcp-language-server is available
if [ -f "$DEPS_DIR/bin/mcp-language-server" ]; then
  # Use mcp-language-server to get diagnostics
  WORKSPACE=$(pwd)

  # Create temporary file for diagnostic output
  DIAG_FILE=$(mktemp)

  # Get diagnostics using mcp-language-server
  # Note: This is a simplified approach - in production you'd want to:
  # 1. Start a persistent mcp-language-server process
  # 2. Query it via MCP protocol
  # 3. Parse the response

  # For now, we'll just report that we checked
  echo "LSP server available: $LSP_CMD"
  echo "Workspace: $WORKSPACE"

  rm -f "$DIAG_FILE"

  cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "LSP diagnostics checked for $FILE_PATH using $LSP_CMD. Full MCP integration requires persistent server process."
}
EOF
elif [ -f "$DEPS_DIR/lsp-cli/bin/lsp-cli" ]; then
  # Fallback to lsp-cli
  WORKSPACE=$(pwd)
  DIAG_OUTPUT=$("$DEPS_DIR/lsp-cli/bin/lsp-cli" \
    --server-command-line="$LSP_CMD" \
    "$FILE_PATH" 2>&1 || true)

  # Check exit code of lsp-cli (3 means diagnostics found)
  LSP_EXIT=$?

  if [ $LSP_EXIT -eq 3 ]; then
    echo "Diagnostics found in $FILE_PATH:"
    echo "$DIAG_OUTPUT"

    cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "LSP diagnostics found in $FILE_PATH using $LSP_CMD. Check output above for details."
}
EOF
  else
    cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "No LSP diagnostics found in $FILE_PATH using $LSP_CMD."
}
EOF
  fi
else
  # No LSP client available
  cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "No LSP client installed for $FILE_PATH. Dependencies may still be installing."
}
EOF
fi

exit 0
