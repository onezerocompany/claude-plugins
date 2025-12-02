#!/usr/bin/env bash
# Validate file format before writing changes

set -euo pipefail

# Use CLAUDE_PLUGIN_ROOT if available, otherwise derive from script location
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
fi

DEPS_DIR="$PLUGIN_ROOT/.deps"

# Read the tool parameters from stdin
TOOL_INPUT=$(cat)

# Extract file path and content from the tool parameters
FILE_PATH=$(echo "$TOOL_INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "")

if [ -z "$FILE_PATH" ]; then
  # No file path found, allow the operation
  exit 0
fi

# Get file extension to determine if we should validate
EXT="${FILE_PATH##*.}"

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check formatting based on file type
check_format() {
  local file="$1"
  local ext="$2"

  case "$ext" in
    ts|tsx|js|jsx|mjs|cjs)
      # Check for prettier first, then eslint
      if command_exists prettier || [ -f "$DEPS_DIR/node_modules/.bin/prettier" ]; then
        local prettier_cmd="prettier"
        [ -f "$DEPS_DIR/node_modules/.bin/prettier" ] && prettier_cmd="$DEPS_DIR/node_modules/.bin/prettier"

        echo "Checking format with prettier..."
        if $prettier_cmd --check "$file" >/dev/null 2>&1; then
          return 0
        else
          echo "File needs formatting (prettier)"
          return 1
        fi
      elif command_exists biome || [ -f "$DEPS_DIR/node_modules/.bin/biome" ]; then
        local biome_cmd="biome"
        [ -f "$DEPS_DIR/node_modules/.bin/biome" ] && biome_cmd="$DEPS_DIR/node_modules/.bin/biome"

        echo "Checking format with biome..."
        if $biome_cmd check "$file" >/dev/null 2>&1; then
          return 0
        else
          echo "File needs formatting (biome)"
          return 1
        fi
      fi
      ;;

    py|pyi)
      # Check for black or ruff
      if command_exists black; then
        echo "Checking format with black..."
        if black --check "$file" >/dev/null 2>&1; then
          return 0
        else
          echo "File needs formatting (black)"
          return 1
        fi
      elif command_exists ruff; then
        echo "Checking format with ruff..."
        if ruff format --check "$file" >/dev/null 2>&1; then
          return 0
        else
          echo "File needs formatting (ruff)"
          return 1
        fi
      fi
      ;;

    go)
      if command_exists gofmt || [ -f "$DEPS_DIR/bin/gofmt" ]; then
        echo "Checking format with gofmt..."
        local gofmt_cmd="gofmt"
        [ -f "$DEPS_DIR/bin/gofmt" ] && gofmt_cmd="$DEPS_DIR/bin/gofmt"

        if [ -z "$($gofmt_cmd -l "$file")" ]; then
          return 0
        else
          echo "File needs formatting (gofmt)"
          return 1
        fi
      fi
      ;;

    rs)
      if command_exists rustfmt; then
        echo "Checking format with rustfmt..."
        if rustfmt --check "$file" >/dev/null 2>&1; then
          return 0
        else
          echo "File needs formatting (rustfmt)"
          return 1
        fi
      fi
      ;;

    c|cpp|h|hpp|cc|cxx)
      if command_exists clang-format; then
        echo "Checking format with clang-format..."
        local formatted=$(clang-format "$file")
        local original=$(cat "$file")
        if [ "$formatted" = "$original" ]; then
          return 0
        else
          echo "File needs formatting (clang-format)"
          return 1
        fi
      fi
      ;;

    java)
      if command_exists google-java-format || [ -f "$DEPS_DIR/bin/google-java-format" ]; then
        echo "Checking format with google-java-format..."
        # Java formatters typically require running
        return 0
      fi
      ;;

    *)
      # No formatter available for this type
      return 0
      ;;
  esac

  # If no formatter is available, allow the file
  return 0
}

# List of extensions we care about
case "$EXT" in
  ts|tsx|js|jsx|mjs|cjs|py|pyi|go|rs|java|c|cpp|h|hpp|cc|cxx|rb|cs|ex|exs|lua|zig|swift)
    echo "Validating format for $EXT file: $FILE_PATH"

    if [ -f "$FILE_PATH" ]; then
      if check_format "$FILE_PATH" "$EXT"; then
        cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "allow"
  },
  "systemMessage": "File $FILE_PATH is properly formatted."
}
EOF
      else
        # Format check failed, but still allow (just warn)
        cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "allow"
  },
  "systemMessage": "Warning: File $FILE_PATH may need formatting, but allowing operation."
}
EOF
      fi
    else
      # File doesn't exist yet (new file), allow it
      cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "allow"
  },
  "systemMessage": "New file $FILE_PATH will be created."
}
EOF
    fi
    ;;
  *)
    # Not a file type we validate, allow it
    cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "allow"
  },
  "systemMessage": "File type .$EXT is not validated by format checker."
}
EOF
    ;;
esac

exit 0
