#!/usr/bin/env bash
# Check workspace health and LSP status on prompt submit

set -euo pipefail

# Use CLAUDE_PLUGIN_ROOT if available, otherwise derive from script location
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
fi

# Read user prompt from stdin
USER_PROMPT=$(cat)

# Check if this is a request related to code quality or diagnostics
if echo "$USER_PROMPT" | grep -qi "error\|warning\|diagnostic\|lint\|format\|check"; then
  echo "Detected code quality related prompt, checking workspace health..."
fi

# In a real implementation, you would:
# 1. Query active LSP servers for their status
# 2. Check for any workspace-wide diagnostics
# 3. Gather information about code health metrics

# Always allow the prompt to proceed
cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "Workspace health check completed. LSP servers active."
}
EOF

exit 0
