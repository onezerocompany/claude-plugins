#!/usr/bin/env bash
# Get the LSP command for a given file or project type

set -euo pipefail

# Always get script directory for config file location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Use CLAUDE_PLUGIN_ROOT if available, otherwise derive from script location
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
fi

DEPS_DIR="$PLUGIN_ROOT/.deps"
CONFIG_FILE="$SCRIPT_DIR/lsp-config.json"

# Get file extension or language type
LANG_TYPE="${1:-}"
FILE_PATH="${2:-}"

if [ -z "$LANG_TYPE" ] && [ -n "$FILE_PATH" ]; then
  # Extract extension from file path
  LANG_TYPE="${FILE_PATH##*.}"
fi

if [ -z "$LANG_TYPE" ]; then
  echo "Usage: $0 <language-type> [file-path]"
  echo "Example: $0 typescript"
  echo "Example: $0 '' file.ts"
  exit 1
fi

# Map extension to language type if needed
case "$LANG_TYPE" in
  ts|tsx|js|jsx|mjs|cjs)
    LANG="typescript"
    ;;
  go)
    LANG="go"
    ;;
  rs)
    LANG="rust"
    ;;
  py|pyi)
    LANG="python"
    ;;
  java)
    LANG="java"
    ;;
  rb)
    LANG="ruby"
    ;;
  c|cpp|h|hpp|cc|cxx)
    LANG="cpp"
    ;;
  cs|csx)
    LANG="csharp"
    ;;
  ex|exs)
    LANG="elixir"
    ;;
  lua)
    LANG="lua"
    ;;
  zig)
    LANG="zig"
    ;;
  swift)
    LANG="swift"
    ;;
  vue)
    LANG="vue"
    ;;
  svelte)
    LANG="svelte"
    ;;
  astro)
    LANG="astro"
    ;;
  *)
    LANG="$LANG_TYPE"
    ;;
esac

# Check if jq is available
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not installed"
  exit 1
fi

# Get configuration for the language
SERVER_CONFIG=$(jq -r ".servers[\"$LANG\"]" "$CONFIG_FILE")

if [ "$SERVER_CONFIG" = "null" ]; then
  echo "No LSP server configured for language: $LANG"
  exit 1
fi

# Check if disabled
DISABLED=$(echo "$SERVER_CONFIG" | jq -r '.disabled')
if [ "$DISABLED" = "true" ]; then
  echo "LSP server for $LANG is disabled"
  exit 1
fi

# Get command and args
COMMAND=$(echo "$SERVER_CONFIG" | jq -r '.command')
ARGS=$(echo "$SERVER_CONFIG" | jq -r '.args | join(" ")')

# Check if command exists in PATH or in deps
FULL_COMMAND=""
if command -v "$COMMAND" >/dev/null 2>&1; then
  FULL_COMMAND="$COMMAND"
elif [ -f "$DEPS_DIR/bin/$COMMAND" ]; then
  FULL_COMMAND="$DEPS_DIR/bin/$COMMAND"
elif [ -f "$DEPS_DIR/node_modules/.bin/$COMMAND" ]; then
  FULL_COMMAND="$DEPS_DIR/node_modules/.bin/$COMMAND"
else
  echo "LSP server $COMMAND not found for language: $LANG"
  echo "Install it or check the configuration in: $CONFIG_FILE"
  exit 1
fi

# Output the full command
echo "$FULL_COMMAND $ARGS"
exit 0
