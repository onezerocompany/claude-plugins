# Plugin Development Guide

A comprehensive guide to developing Claude Code plugins with best practices, detailed examples, and solutions for common scenarios.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Plugin Manifest (plugin.json)](#plugin-manifest-pluginjson)
3. [Writing Commands](#writing-commands)
4. [Writing Agents](#writing-agents)
5. [Writing Skills](#writing-skills)
6. [Hooks Integration](#hooks-integration)
7. [MCP Server Integration](#mcp-server-integration)
8. [Testing Your Plugin](#testing-your-plugin)
9. [Publishing](#publishing)
10. [Best Practices](#best-practices)
11. [Troubleshooting](#troubleshooting)

---

## Getting Started

### Prerequisites

Before developing plugins, ensure you have:

- **[Bun](https://bun.sh/)** - JavaScript runtime (v1.0+)
- **[mise](https://mise.jdx.dev/)** (optional) - Tool version management
- **[Claude Code](https://code.claude.com/)** - The Claude Code CLI
- **Git** - Version control

### Installation

#### Install mise (recommended)

```bash
# macOS/Linux
curl https://mise.run | sh

# Or with Homebrew
brew install mise
```

#### Install Bun

```bash
# Via mise (if using .mise.toml)
mise install

# Or install Bun directly
curl -fsSL https://bun.sh/install | bash
```

### Creating Your First Plugin

1. **Choose a plugin location:**
   - Local plugin: In the marketplace repository under `plugins/your-plugin-name/`
   - External plugin: In your own repository

2. **Create the basic structure:**

```bash
# If contributing to this marketplace
cd plugins
mkdir my-awesome-plugin
cd my-awesome-plugin

# Create required directories
mkdir -p .claude-plugin
mkdir -p commands    # Optional: for slash commands
mkdir -p agents      # Optional: for autonomous agents
mkdir -p skills      # Optional: for skill definitions
mkdir -p hooks       # Optional: for event hooks
```

3. **Create essential files:**

```bash
touch .claude-plugin/plugin.json
touch README.md
touch LICENSE
```

### Plugin Structure Overview

A complete plugin directory looks like this:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (REQUIRED)
├── commands/                # Slash commands (optional)
│   ├── my-command.md
│   └── another-command.md
├── agents/                  # Autonomous agents (optional)
│   └── my-agent.md
├── skills/                  # Skill definitions (optional)
│   └── my-skill.md
├── hooks/                   # Event hooks (optional)
│   └── pre-commit.sh
├── README.md                # Documentation (REQUIRED)
└── LICENSE                  # License file (REQUIRED)
```

**Key Points:**
- `.claude-plugin/plugin.json` is the only required file for functionality
- At least one component type (commands, agents, skills, or hooks) must be present
- `README.md` and `LICENSE` are required for marketplace submission
- All paths in `plugin.json` are relative to the plugin root

---

## Plugin Manifest (plugin.json)

The manifest file defines your plugin's metadata and components.

### Minimal Example

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "A brief description of what this plugin does",
  "author": {
    "name": "Your Name",
    "email": "your@email.com"
  },
  "license": "MIT"
}
```

### Complete Example

```json
{
  "name": "my-awesome-plugin",
  "version": "1.2.3",
  "description": "Comprehensive description of plugin functionality and use cases",
  "author": {
    "name": "Your Name",
    "email": "your@email.com"
  },
  "homepage": "https://github.com/yourusername/your-plugin-repo",
  "license": "MIT",
  "keywords": [
    "productivity",
    "automation",
    "git",
    "documentation"
  ],
  "commands": [
    "./commands/main-command.md",
    "./commands/helper-command.md"
  ],
  "agents": [
    "./agents/specialist-agent.md"
  ],
  "skills": [
    "./skills/domain-expert.md"
  ],
  "hooks": [
    "./hooks/pre-commit.sh"
  ],
  "mcpServers": {
    "custom-server": {
      "command": "node",
      "args": ["./mcp-server/index.js"]
    }
  }
}
```

### Field Reference

#### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `name` | string | Unique plugin identifier (lowercase, hyphens) | `"commit-helper"` |
| `version` | string | Semantic version (major.minor.patch) | `"1.0.0"` |
| `description` | string | Clear, concise plugin description | `"AI-powered commit message generator"` |
| `author` | object | Author information with name and email | `{"name": "...", "email": "..."}` |
| `license` | string | License identifier (SPDX format preferred) | `"MIT"`, `"Apache-2.0"` |

#### Optional Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `homepage` | string | Plugin homepage or repository URL | `"https://github.com/user/repo"` |
| `keywords` | array | Search keywords for discoverability | `["git", "automation"]` |
| `commands` | array | Paths to command definition files | `["./commands/cmd.md"]` |
| `agents` | array | Paths to agent definition files | `["./agents/agent.md"]` |
| `skills` | array | Paths to skill definition files | `["./skills/skill.md"]` |
| `hooks` | array | Paths to hook script files | `["./hooks/pre-commit.sh"]` |
| `mcpServers` | object | MCP server configurations | See MCP section |

### Component Types

#### Commands
Slash commands that users invoke explicitly (e.g., `/commit`, `/cleanup`).

#### Agents
Autonomous assistants that handle complex, multi-step tasks with their own specialized instructions.

#### Skills
Knowledge modules that enhance Claude's expertise in specific domains without creating new commands.

#### Hooks
Scripts that execute at specific lifecycle events (e.g., before commits, on file save).

#### MCP Servers
Model Context Protocol servers that provide external tool integrations.

### Versioning Guidelines

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** version (1.0.0 → 2.0.0): Breaking changes, incompatible API changes
- **MINOR** version (1.0.0 → 1.1.0): New features, backward-compatible
- **PATCH** version (1.0.0 → 1.0.1): Bug fixes, backward-compatible

**Examples:**
- Adding a new command: Minor version bump (1.0.0 → 1.1.0)
- Fixing a bug in a command: Patch version bump (1.0.0 → 1.0.1)
- Changing command arguments (breaking): Major version bump (1.0.0 → 2.0.0)
- Renaming a command: Major version bump (1.0.0 → 2.0.0)

### Keywords for Discoverability

Choose keywords that help users find your plugin:

**Good keywords:**
- Technology/tool names: `"git"`, `"docker"`, `"typescript"`
- Use cases: `"automation"`, `"testing"`, `"documentation"`
- Domain areas: `"security"`, `"performance"`, `"ci-cd"`
- Actions: `"analysis"`, `"generation"`, `"validation"`

**Avoid:**
- Generic terms: `"helper"`, `"utility"`, `"tool"`
- Redundant info: `"claude"`, `"plugin"`, `"code"`
- Your plugin name (it's already searchable by name)

**Example - Good keyword selection:**
```json
{
  "name": "commit-authoring",
  "keywords": ["git", "commit", "version-control", "automation", "cleanup"]
}
```

---

## Writing Commands

Commands are user-invoked actions that trigger specific behavior. They appear as slash commands in Claude Code (e.g., `/commit`, `/cleanup`).

### Command File Format

Commands are defined in Markdown files with YAML frontmatter:

```markdown
---
name: command-name
description: Brief description shown in command list
---

# Command Title

Detailed instructions for Claude on how to handle this command.

## Instructions

What Claude should do when this command is invoked...
```

### Minimal Command Example

```markdown
---
name: hello
description: Say hello to the user
---

# Hello Command

When the user runs `/hello`, greet them warmly and ask how you can help with their coding tasks today.
```

### Command with Arguments

```markdown
---
name: commit
description: Analyze git changes and create a well-crafted commit with an AI-generated message
---

# Commit Command

Analyze the current git changes and create a well-crafted commit with an AI-generated message.

## Instructions

You are helping the user create a git commit. Use the commit-author agent to analyze changes and generate an appropriate commit message.

### Process

1. **Activate the Agent**: Invoke the `commit-author` agent to handle the commit process
2. **Agent Will**:
   - Analyze staged and unstaged changes
   - Review recent commit history for style consistency
   - Generate an appropriate commit message following conventions
   - Ask for user approval before committing

### Arguments

The user may provide additional context:
- `/commit` - Standard commit process
- `/commit [context]` - Include user-provided context in the analysis

When context is provided, pass it to the agent to help inform the commit message.

### Example Usage

When the user runs `/commit`, immediately spawn the commit-author agent:

```
I'll analyze your changes and help create a commit. Let me hand this over to the commit-author agent.
```

Then invoke the commit-author agent with any provided context.

### Notes

- The agent will handle all git operations
- Users can provide additional context by running `/commit [context]`
- The agent will never commit without explicit user approval
```

### Command Best Practices

#### 1. Clear, Actionable Names

**Good:**
```yaml
name: commit
name: cleanup
name: doc-check
name: generate-workflow
```

**Avoid:**
```yaml
name: doTheCommitThing
name: helper
name: run
```

#### 2. Concise Descriptions

**Good:**
```yaml
description: Analyze git changes and create a well-crafted commit
description: Clean up staging area and identify unwanted files
```

**Avoid:**
```yaml
description: This command helps you to maybe commit your code changes if you want
description: A super amazing helper that does commits
```

#### 3. Structured Instructions

Use clear sections:
```markdown
## Instructions
What to do when invoked

## Process
Step-by-step workflow

## Arguments
How to handle user input

## Example Usage
Show expected behavior

## Notes
Important caveats or tips
```

#### 4. Argument Handling

**Pattern 1: Optional context**
```markdown
### Arguments
- `/command` - Default behavior
- `/command [context]` - Enhanced behavior with user context
```

**Pattern 2: Required parameters**
```markdown
### Arguments
The command requires a target path:
- `/command <path>` - Process the specified path

If no path is provided, prompt the user to specify one.
```

**Pattern 3: Multiple arguments**
```markdown
### Arguments
- `/command` - Interactive mode (ask for details)
- `/command <file>` - Process specific file
- `/command <file> --format json` - Process with format option
```

#### 5. Delegate to Agents for Complex Tasks

Commands should be lightweight. For complex multi-step tasks, invoke an agent:

```markdown
## Instructions

When the user runs this command:

1. Acknowledge the request
2. Invoke the `specialist-agent` agent to handle the complex workflow
3. Pass any user-provided arguments to the agent

The agent will handle all the detailed work.
```

### Advanced Command Patterns

#### Interactive Command

```markdown
---
name: setup-config
description: Interactive configuration setup
---

# Setup Config Command

Guide the user through setting up their configuration file.

## Instructions

1. **Check for existing config**: Look for `.myconfig` file
2. **If exists**: Ask if they want to modify or recreate
3. **If not exists**: Proceed with creation
4. **Interactive prompts**:
   - Ask for required fields (name, email, etc.)
   - Offer sensible defaults
   - Validate input format
5. **Create/update**: Write the configuration file
6. **Confirm**: Show the final config and ask for approval

## Example Flow

```
User: /setup-config
Assistant: I'll help you set up your configuration. Let me check if you have an existing config...
[Checks for .myconfig file]
No existing configuration found. Let's create one.

What's your name? (This will be used for attribution)
User: John Doe

What's your email?
User: john@example.com

[Creates config file with the provided information]

Here's your configuration:
{
  "name": "John Doe",
  "email": "john@example.com",
  "created": "2024-01-15"
}

Does this look correct? (yes/no)
```
```

#### Command with Validation

```markdown
---
name: validate-config
description: Validate configuration files against schema
---

# Validate Config Command

Validate configuration files to ensure they meet requirements.

## Instructions

1. **Determine target**:
   - If user provides path: `/validate-config <path>`
   - If no path: Look for common config files (.myconfig, config.json, etc.)
2. **Read file**: Load the configuration file
3. **Validate**:
   - Check JSON/YAML syntax
   - Verify required fields are present
   - Validate field types and formats
   - Check for deprecated options
4. **Report**:
   - List all errors with line numbers
   - Suggest fixes for common issues
   - Highlight warnings (non-critical issues)
5. **Offer fix**: If issues found, offer to auto-fix if possible

## Error Handling

- **File not found**: Suggest creating a new config
- **Parse error**: Show exact location and nature of syntax error
- **Validation error**: Explain what's wrong and how to fix it
- **Permission error**: Explain the issue and required permissions
```

---

## Writing Agents

Agents are autonomous assistants with specialized knowledge and capabilities. Unlike commands, agents can perform multi-step workflows and make decisions independently.

### When to Use Agents vs Commands

**Use a Command when:**
- Simple, single-purpose action
- Direct user invocation is the primary interface
- Minimal decision-making required
- Quick response expected

**Use an Agent when:**
- Complex, multi-step workflow
- Requires analysis and decision-making
- May need to use multiple tools
- Context-aware behavior needed
- Delegated from a command

**Example - Command delegates to Agent:**
```markdown
<!-- commands/commit.md -->
---
name: commit
description: Create a well-crafted git commit
---

When the user runs `/commit`, invoke the `commit-author` agent to handle the analysis and commit process.
```

```markdown
<!-- agents/commit-author.md -->
---
name: commit-author
description: Specialized agent for analyzing changes and creating commits
model: inherit
color: green
---

You are a git commit specialist. Analyze changes, generate conventional commit messages, and create commits following best practices...
```

### Agent File Format

Agents are defined in Markdown files with YAML frontmatter:

```markdown
---
name: agent-name
description: When to use this agent with examples
model: inherit|sonnet|opus|haiku
color: green|blue|red|yellow|purple
---

# Agent Instructions

Detailed instructions for the agent's behavior, responsibilities, and decision-making process.
```

### Minimal Agent Example

```markdown
---
name: code-reviewer
description: Reviews code for quality, bugs, and best practices
model: inherit
color: blue
---

You are a code review specialist. Review the provided code for:
1. Bugs and edge cases
2. Code quality and readability
3. Best practices and patterns
4. Performance concerns
5. Security vulnerabilities

Provide constructive, specific feedback with examples.
```

### Complete Agent Example

```markdown
---
name: commit-author
description: Use this agent when the user wants to create a git commit with an AI-generated message. Examples:

  <example>
  Context: User has staged changes and wants to commit
  user: "Create a commit for these changes"
  assistant: "I'll analyze your changes and help create a commit. Let me hand this over to the commit-author agent."
  <commentary>
  The commit-author agent specializes in analyzing git changes and generating appropriate commit messages following best practices.
  </commentary>
  </example>

  <example>
  Context: User runs /commit command
  user: "/commit"
  assistant: "I'll help you create a commit. Invoking the commit-author agent to analyze your changes."
  <commentary>
  The /commit command should always trigger the commit-author agent.
  </commentary>
  </example>

model: inherit
color: green
---

You are a git commit message specialist. Your role is to analyze code changes and create clear, meaningful commit messages that follow best practices.

# Your Responsibilities

1. **Analyze Changes**: Review git diff, staged files, and recent commit history to understand the context
2. **Generate Message**: Create a concise, informative commit message following conventional commits format when appropriate
3. **Follow Convention**: Use prefixes like feat:, fix:, docs:, refactor:, test:, chore:, etc.
4. **Be Specific**: Focus on the 'why' behind changes, not just the 'what'
5. **Keep it Concise**: First line should be 50-72 characters, detailed body if needed

# Process

1. Run `git status` to see all changes
2. Run `git diff --cached` to see staged changes (if any)
3. Run `git diff` to see unstaged changes
4. Run `git log -3 --oneline` to understand recent commit style
5. Analyze the nature of changes (new feature, bug fix, refactor, etc.)
6. Draft a commit message that:
   - Starts with a conventional commit prefix if appropriate
   - Summarizes changes clearly in imperative mood
   - Includes detailed explanation in body if changes are complex
   - References issue numbers if mentioned in changed files

# Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: feat, fix, docs, style, refactor, perf, test, chore, ci, build

# Important Rules

- NEVER commit without user approval
- ALWAYS show the proposed commit message and ask for confirmation
- If changes include multiple unrelated modifications, suggest splitting into separate commits
- If no files are staged, ask which files to stage first
- Check for sensitive data (API keys, passwords) before committing
- Respect existing commit message style in the repository

# Output Format

Present your analysis and proposal like this:

```
## Commit Analysis

**Files Changed**: [list key files]
**Change Type**: [feat/fix/refactor/etc.]
**Scope**: [affected component/module]

## Proposed Commit Message

```
[Your proposed commit message]
```

## Changes Summary
[Brief explanation of what changed and why]

Proceed with this commit? (I can also help you stage/unstage files first)
```

Be helpful, thorough, and never commit without explicit user approval.
```

### Agent Frontmatter Fields

#### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `name` | string | Unique agent identifier | `"commit-author"` |
| `description` | string | When to use this agent, with examples | See example above |

#### Optional Fields

| Field | Type | Options | Description |
|-------|------|---------|-------------|
| `model` | string | `inherit`, `sonnet`, `opus`, `haiku` | Model to use (default: `inherit`) |
| `color` | string | `green`, `blue`, `red`, `yellow`, `purple` | Visual indicator color |

### Description Field Best Practices

The description should help Claude know when to invoke this agent. Include:

1. **Clear trigger conditions**
2. **Example scenarios with `<example>` tags**
3. **Commentary explaining why the agent is appropriate**

```markdown
description: Use this agent when [condition]. Examples:

  <example>
  Context: [situation]
  user: "[user request]"
  assistant: "[handoff message]"
  <commentary>
  [Why this agent is the right choice]
  </commentary>
  </example>
```

### Model Selection

- **`inherit`** (default): Use the same model as the parent conversation
- **`sonnet`**: Balanced performance and capability (recommended for most agents)
- **`opus`**: Maximum capability for complex reasoning
- **`haiku`**: Fast, cost-effective for simple tasks

### Color Coding

Colors provide visual distinction:
- **`green`**: Utility agents (commit, cleanup, formatting)
- **`blue`**: Analysis agents (review, audit, documentation)
- **`red`**: Critical/security agents (security review, validation)
- **`yellow`**: Warning/advisory agents (deprecation, migration)
- **`purple`**: Creative agents (generation, design)

### Agent Instruction Patterns

#### Pattern 1: Step-by-Step Process

```markdown
# Process

1. First, do X
2. Then, analyze Y
3. Next, evaluate Z
4. Finally, present findings

Always follow this order for consistency.
```

#### Pattern 2: Decision Tree

```markdown
# Decision Process

1. **Check condition A**:
   - If true: Do action X
   - If false: Proceed to condition B

2. **Check condition B**:
   - If true: Do action Y
   - If false: Ask user for clarification

3. Present results and recommendations
```

#### Pattern 3: Responsibility-Based

```markdown
# Your Responsibilities

## Analysis Phase
- Gather relevant information
- Identify patterns and issues
- Assess severity and impact

## Recommendation Phase
- Propose solutions
- Explain trade-offs
- Prioritize actions

## Execution Phase
- Implement approved changes
- Validate results
- Confirm completion
```

### Advanced Agent Patterns

#### Specialist Agent with Tool Restrictions

```markdown
---
name: security-auditor
description: Security-focused code review agent
model: opus
color: red
---

You are a security specialist focused exclusively on finding vulnerabilities.

# Tools You Should Use

- **Read**: To examine source code
- **Grep**: To search for security patterns
- **Glob**: To find security-relevant files

# Tools You Should NOT Use

- Do NOT make any code changes (Write, Edit)
- Do NOT run any bash commands
- Do NOT modify files

# Focus Areas

1. **Injection vulnerabilities**: SQL, NoSQL, Command, LDAP
2. **Authentication flaws**: Session management, token handling
3. **Data exposure**: Sensitive information in logs, errors, responses
4. **Access control**: Authorization checks, privilege escalation
5. **Cryptography**: Weak algorithms, poor key management

# Severity Classification

- **CRITICAL**: Immediate exploit possible, high impact
- **HIGH**: Exploit likely, significant impact
- **MEDIUM**: Exploit possible under certain conditions
- **LOW**: Minor issue, limited impact
- **INFO**: Best practice recommendation

# Output Format

For each finding:

```
## [SEVERITY] [Vulnerability Type]

**Location**: file.ts:123
**Description**: [What's wrong]
**Impact**: [What could happen]
**Recommendation**: [How to fix]
**Example**: [Code example if helpful]
```
```

#### Collaborative Agent

```markdown
---
name: workflow-expert
description: Expert in GitHub Actions and Claude Code Action workflows
model: sonnet
color: blue
---

You are an expert in creating secure, production-ready GitHub workflows using the `anthropics/claude-code-action`.

# Your Expertise

- Latest claude-code-action v1.0.x patterns
- Security best practices for CI/CD
- OIDC authentication with cloud providers
- GitHub Actions permissions model
- Workflow optimization and debugging

# Collaboration Style

1. **Ask clarifying questions** before generating workflows
2. **Explain your recommendations** with rationale
3. **Offer alternatives** when multiple approaches exist
4. **Educate while implementing** - help users understand choices

# When Users Ask for Workflows

1. **Understand requirements**:
   - What should trigger the workflow?
   - What should Claude do?
   - What permissions are needed?
   - Any security constraints?

2. **Propose approach**:
   - Suggest workflow structure
   - Explain security implications
   - Offer configuration options

3. **Implement and document**:
   - Generate complete workflow file
   - Add inline comments
   - Explain each section
   - Highlight security considerations

# Security First

Always:
- Use minimal permissions
- Store credentials in secrets
- Validate user inputs
- Restrict tool access
- Enable commit signing when appropriate
- Warn about sensitive data exposure risks
```

---

## Writing Skills

Skills are knowledge modules that enhance Claude's expertise without creating new commands or agents. They're loaded into context when relevant topics are discussed.

### When to Use Skills

**Use a Skill when:**
- You want to teach Claude about a domain/framework/tool
- The knowledge should be available across all conversations
- No specific command invocation is needed
- The expertise should be referenced implicitly

**Examples:**
- Framework documentation (Starlight, React, etc.)
- API references (GitHub Actions, cloud providers)
- Best practices (security patterns, architectural guidelines)
- Domain knowledge (accessibility, performance optimization)

### Skill File Format

Skills are Markdown files with YAML frontmatter:

```markdown
---
name: skill-name
description: When this skill should be activated (keywords and phrases)
---

# Skill Content

Comprehensive information, examples, patterns, and best practices for the domain.
```

### Minimal Skill Example

```markdown
---
name: typescript-expert
description: Use this skill when discussing TypeScript, type systems, interfaces, generics, or TypeScript configuration
---

# TypeScript Expert

## Type System Fundamentals

TypeScript provides static typing for JavaScript...

## Common Patterns

### Interface vs Type Alias
[Explanation and examples]

### Generic Constraints
[Explanation and examples]

## Best Practices

1. Prefer interfaces for object shapes
2. Use strict mode
3. Avoid `any` type
...
```

### Complete Skill Example

```markdown
---
name: claude-code-action-expert
description: Use this skill when the user asks about "claude-code-action", "GitHub workflows with Claude", "Claude GitHub Action", "automated PR reviews with Claude", "Claude CI/CD", "claude.yml workflow", creating GitHub Actions that use Claude, or needs guidance on claude-code-action configuration, security, authentication, triggers, or best practices.
---

# Claude Code Action Expert

You are an expert in creating secure, production-ready GitHub workflows using the `anthropics/claude-code-action`. This skill provides comprehensive knowledge of the latest version (v1.0.x) patterns, configuration options, and security best practices.

## Current Version Information

- **Latest Stable Version**: `anthropics/claude-code-action@v1`
- **Current Release**: v1.0.22 (December 2024)
- **Always use `@v1`** - this tracks the latest v1.x release with bug fixes

## Action Overview

Claude Code Action is a flexible GitHub automation platform that auto-detects execution mode based on workflow context...

## Complete Input Reference

### Trigger Configuration

| Input | Description | Default |
|-------|-------------|---------|
| `trigger_phrase` | Phrase to look for in comments | `@claude` |
| `assignee_trigger` | Username that triggers when assigned | - |
| `label_trigger` | Label that triggers the action | `claude` |

[Continue with comprehensive documentation]

## Authentication Methods

### 1. Anthropic API Key (Recommended)

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

[More authentication methods with examples]

## Security Best Practices

### 1. Credential Storage

**NEVER hardcode credentials in workflow files!**

[Security guidelines with examples]

## Workflow Templates

### Basic Interactive Workflow

```yaml
[Complete, working example]
```

[More templates for common scenarios]
```

### Skill Best Practices

#### 1. Comprehensive Coverage

Include:
- **Overview**: What this skill provides
- **Current information**: Version numbers, latest patterns
- **Reference tables**: Quick lookups for options/configurations
- **Examples**: Working code samples
- **Best practices**: Dos and don'ts
- **Troubleshooting**: Common issues and solutions

#### 2. Structured Organization

Use clear hierarchy:
```markdown
# Main Topic

## Subtopic 1

### Specific Area

#### Detail Level

- Bullet points for lists
- Code blocks for examples
- Tables for reference data
```

#### 3. Searchable Keywords

The `description` field should include:
- Explicit terms users might mention
- Related concepts and synonyms
- Common questions or tasks
- Framework/tool names

#### 4. Actionable Information

**Good** - Specific and actionable:
```markdown
## Authentication

Use this pattern for API key authentication:

\`\`\`yaml
- uses: action@v1
  with:
    api_key: ${{ secrets.API_KEY }}
\`\`\`

NEVER hardcode credentials. Always use GitHub secrets.
```

**Bad** - Vague and theoretical:
```markdown
## Authentication

Authentication is important for security. There are different ways to authenticate.
```

#### 5. Keep Updated

Skills should reflect current best practices:
- Include version numbers
- Date time-sensitive information
- Note deprecated patterns
- Highlight new features

### Skill Organization Patterns

#### Pattern 1: API Reference Style

```markdown
# Tool/Framework Name

## Overview
Brief introduction and use cases

## Installation
How to set up

## Core Concepts
Fundamental ideas to understand

## API Reference

### Component/Function 1
- **Purpose**: What it does
- **Parameters**: What it accepts
- **Returns**: What it provides
- **Example**: How to use it

### Component/Function 2
[Same structure]

## Common Patterns
Frequently used combinations

## Best Practices
Guidelines for effective use

## Troubleshooting
Common issues and solutions
```

#### Pattern 2: Domain Knowledge Style

```markdown
# Domain Area

## Fundamentals
Core principles and concepts

## Common Scenarios

### Scenario 1
Problem description and solutions

### Scenario 2
Problem description and solutions

## Advanced Topics

### Topic 1
Deep dive with examples

### Topic 2
Deep dive with examples

## Decision Frameworks

When to use approach A vs B vs C:
- Use A when...
- Use B when...
- Use C when...

## Anti-Patterns
What to avoid and why

## Resources
Links to external documentation
```

---

## Hooks Integration

Hooks allow plugins to execute scripts at specific lifecycle events in the development workflow.

### Available Hook Types

| Hook Type | When It Fires | Common Use Cases |
|-----------|---------------|------------------|
| `pre-commit` | Before creating a commit | Linting, formatting, tests |
| `post-commit` | After commit is created | Notifications, logging |
| `pre-push` | Before pushing to remote | Final validation, build checks |
| `on-save` | When a file is saved | Auto-formatting, live validation |

**Note**: Hook availability depends on Claude Code version and configuration. Check the official documentation for the complete list.

### Hook Script Format

Hooks are executable scripts (bash, node, python, etc.):

```bash
#!/bin/bash
# hooks/pre-commit.sh

# Exit on error
set -e

echo "Running pre-commit checks..."

# Your validation logic here
npm run lint
npm run test

echo "All checks passed!"
exit 0
```

### Hook Configuration in plugin.json

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "hooks": [
    "./hooks/pre-commit.sh",
    "./hooks/pre-push.sh"
  ]
}
```

### Example: Pre-Commit Linter Hook

```bash
#!/bin/bash
# hooks/pre-commit.sh

set -e

echo " Applying TypeScript Linter..."

# Get list of staged .ts and .tsx files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|tsx)$' || true)

if [ -z "$STAGED_FILES" ]; then
  echo "✓ No TypeScript files to lint"
  exit 0
fi

echo "Linting files:"
echo "$STAGED_FILES"

# Run eslint on staged files
npx eslint $STAGED_FILES

if [ $? -eq 0 ]; then
  echo "✓ Linting passed"
  exit 0
else
  echo "✗ Linting failed - please fix errors before committing"
  exit 1
fi
```

### Example: Pre-Commit Formatter Hook

```bash
#!/bin/bash
# hooks/pre-commit-format.sh

set -e

echo " Auto-formatting staged files..."

# Get staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if [ -z "$STAGED_FILES" ]; then
  echo "No files to format"
  exit 0
fi

# Format files
npx prettier --write $STAGED_FILES

# Re-stage formatted files
git add $STAGED_FILES

echo "✓ Files formatted and re-staged"
exit 0
```

### Example: Pre-Push Test Hook

```bash
#!/bin/bash
# hooks/pre-push.sh

set -e

echo " Running tests before push..."

# Run test suite
npm run test

if [ $? -eq 0 ]; then
  echo "✓ All tests passed"
  exit 0
else
  echo "✗ Tests failed - push cancelled"
  echo "Fix failing tests before pushing"
  exit 1
fi
```

### Hook Best Practices

#### 1. Make Scripts Executable

```bash
chmod +x hooks/pre-commit.sh
```

#### 2. Include Shebang

Always start with the appropriate shebang:
```bash
#!/bin/bash          # For bash scripts
#!/usr/bin/env node  # For Node.js scripts
#!/usr/bin/env python3  # For Python scripts
```

#### 3. Exit Codes

- `exit 0`: Success, continue operation
- `exit 1` (or any non-zero): Failure, abort operation

#### 4. Clear User Feedback

```bash
echo "✓ Check passed"
echo "✗ Check failed: reason"
echo " Running operation..."
```

#### 5. Handle Edge Cases

```bash
# Check if command exists
if ! command -v eslint &> /dev/null; then
  echo "eslint not found, skipping lint check"
  exit 0
fi

# Check if files exist
if [ -z "$STAGED_FILES" ]; then
  echo "No relevant files found"
  exit 0
fi
```

#### 6. Performance Considerations

Only process changed files:
```bash
# Good - only lint changed files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.ts$')
npx eslint $STAGED_FILES

# Bad - lint entire codebase every commit
npx eslint src/
```

### Advanced Hook Patterns

#### Multi-Step Validation Hook

```bash
#!/bin/bash
# hooks/pre-commit-comprehensive.sh

set -e

echo " Running comprehensive pre-commit checks..."

# Track if any check fails
FAILURES=0

# Check 1: Linting
echo "\n[1/4] Linting..."
if npm run lint --silent; then
  echo "✓ Linting passed"
else
  echo "✗ Linting failed"
  FAILURES=$((FAILURES + 1))
fi

# Check 2: Type checking
echo "\n[2/4] Type checking..."
if npm run type-check --silent; then
  echo "✓ Type checking passed"
else
  echo "✗ Type checking failed"
  FAILURES=$((FAILURES + 1))
fi

# Check 3: Unit tests
echo "\n[3/4] Running tests..."
if npm run test --silent; then
  echo "✓ Tests passed"
else
  echo "✗ Tests failed"
  FAILURES=$((FAILURES + 1))
fi

# Check 4: Build
echo "\n[4/4] Building..."
if npm run build --silent; then
  echo "✓ Build successful"
else
  echo "✗ Build failed"
  FAILURES=$((FAILURES + 1))
fi

# Summary
echo "\n────────────────────────────────"
if [ $FAILURES -eq 0 ]; then
  echo "✓ All checks passed!"
  exit 0
else
  echo "✗ $FAILURES check(s) failed"
  echo "Please fix the issues before committing"
  exit 1
fi
```

#### Conditional Hook

```bash
#!/bin/bash
# hooks/pre-commit-conditional.sh

set -e

# Only run on certain branches
CURRENT_BRANCH=$(git branch --show-current)

if [[ "$CURRENT_BRANCH" == "main" ]] || [[ "$CURRENT_BRANCH" == "develop" ]]; then
  echo " Running strict checks for protected branch..."
  npm run lint
  npm run test
  npm run build
else
  echo " Running basic checks for feature branch..."
  npm run lint
fi

exit 0
```

---

## MCP Server Integration

Model Context Protocol (MCP) servers provide external tool integrations for Claude Code plugins.

### When to Use MCP Servers

**Use MCP servers when you need:**
- External API integrations
- Database access
- File system operations beyond standard tools
- Custom tool implementations
- Third-party service connections

**Examples:**
- GitHub API integration for issue/PR management
- Database query tools
- Cloud provider CLIs
- Custom build system integrations

### MCP Server Configuration

Configure MCP servers in the `mcpServers` object in `plugin.json`:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "mcpServers": {
    "server-name": {
      "command": "executable",
      "args": ["arg1", "arg2"],
      "env": {
        "VAR_NAME": "value"
      }
    }
  }
}
```

### Example: Node.js MCP Server

```json
{
  "mcpServers": {
    "custom-tools": {
      "command": "node",
      "args": ["./mcp-server/index.js"]
    }
  }
}
```

### Example: Python MCP Server

```json
{
  "mcpServers": {
    "data-processor": {
      "command": "python3",
      "args": ["-m", "mcp_server.main"],
      "env": {
        "PYTHONPATH": "./mcp-server"
      }
    }
  }
}
```

### Example: External CLI Tool

```json
{
  "mcpServers": {
    "github-cli": {
      "command": "gh",
      "args": ["api", "--help"],
      "env": {
        "GH_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### MCP Server Implementation (Node.js Example)

```javascript
// mcp-server/index.js

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server({
  name: "custom-tools",
  version: "1.0.0",
}, {
  capabilities: {
    tools: {},
  },
});

// Define available tools
server.setRequestHandler("tools/list", async () => {
  return {
    tools: [
      {
        name: "process_data",
        description: "Process and transform data",
        inputSchema: {
          type: "object",
          properties: {
            data: {
              type: "string",
              description: "Data to process",
            },
            operation: {
              type: "string",
              enum: ["transform", "validate", "analyze"],
              description: "Operation to perform",
            },
          },
          required: ["data", "operation"],
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler("tools/call", async (request) => {
  if (request.params.name === "process_data") {
    const { data, operation } = request.params.arguments;

    let result;
    switch (operation) {
      case "transform":
        result = transformData(data);
        break;
      case "validate":
        result = validateData(data);
        break;
      case "analyze":
        result = analyzeData(data);
        break;
      default:
        throw new Error(`Unknown operation: ${operation}`);
    }

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  }

  throw new Error(`Unknown tool: ${request.params.name}`);
});

// Helper functions
function transformData(data) {
  return { transformed: data.toUpperCase() };
}

function validateData(data) {
  return { valid: data.length > 0, length: data.length };
}

function analyzeData(data) {
  return {
    length: data.length,
    words: data.split(/\s+/).length,
    chars: data.length,
  };
}

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

### Testing MCP Servers Locally

#### 1. Create a Test Script

```bash
#!/bin/bash
# test-mcp-server.sh

# Start the MCP server
node mcp-server/index.js &
SERVER_PID=$!

# Give it time to start
sleep 1

# Send a test request
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | node mcp-server/index.js

# Cleanup
kill $SERVER_PID
```

#### 2. Use the MCP Inspector

```bash
# Install MCP Inspector
npm install -g @modelcontextprotocol/inspector

# Run your server with the inspector
mcp-inspector node mcp-server/index.js
```

#### 3. Integration Test

Create a test plugin configuration:

```json
{
  "name": "test-plugin",
  "version": "0.0.1",
  "mcpServers": {
    "test-server": {
      "command": "node",
      "args": ["./mcp-server/index.js"]
    }
  },
  "commands": ["./commands/test-mcp.md"]
}
```

Test command:
```markdown
---
name: test-mcp
description: Test MCP server integration
---

# Test MCP Command

When invoked, use the `process_data` tool from the test-server to transform the text "hello world".

Show the result to the user.
```

### MCP Server Best Practices

#### 1. Error Handling

```javascript
server.setRequestHandler("tools/call", async (request) => {
  try {
    // Tool logic
    return { content: [{ type: "text", text: result }] };
  } catch (error) {
    return {
      content: [{
        type: "text",
        text: `Error: ${error.message}`,
      }],
      isError: true,
    };
  }
});
```

#### 2. Input Validation

```javascript
function validateInput(data, schema) {
  // Validate required fields
  for (const field of schema.required || []) {
    if (!(field in data)) {
      throw new Error(`Missing required field: ${field}`);
    }
  }

  // Validate types
  for (const [key, value] of Object.entries(data)) {
    const expectedType = schema.properties[key]?.type;
    const actualType = typeof value;

    if (expectedType && actualType !== expectedType) {
      throw new Error(`Invalid type for ${key}: expected ${expectedType}, got ${actualType}`);
    }
  }

  return true;
}
```

#### 3. Logging

```javascript
function log(level, message, data = {}) {
  console.error(JSON.stringify({
    level,
    message,
    timestamp: new Date().toISOString(),
    ...data,
  }));
}

// Usage
log("info", "Processing request", { toolName: "process_data" });
log("error", "Processing failed", { error: error.message });
```

#### 4. Resource Cleanup

```javascript
// Track resources
const activeConnections = new Set();

// Cleanup on shutdown
process.on("SIGINT", async () => {
  log("info", "Shutting down server");

  // Close all connections
  for (const conn of activeConnections) {
    await conn.close();
  }

  process.exit(0);
});
```

---

## Testing Your Plugin

### Local Development Workflow

#### 1. Install Your Plugin Locally

```bash
# From the marketplace root
cd plugins/your-plugin

# Test that plugin.json is valid
cat .claude-plugin/plugin.json | jq .

# If contributing to this marketplace, the plugin is auto-detected
```

#### 2. Validate Plugin Structure

```bash
# From marketplace root
bun run lint

# This checks:
# - plugin.json has required fields
# - Referenced files exist
# - Markdown files are properly formatted
# - No broken relative paths
```

#### 3. Test Commands

Open Claude Code and test your commands:

```bash
# In Claude Code
/your-command-name
/your-command-name arg1 arg2
```

#### 4. Test Agents

Create a command or skill that invokes your agent, then test the workflow:

```bash
# Test agent invocation
/test-agent

# Or create a conversation that should trigger the agent based on its description
```

#### 5. Test Skills

Discuss topics that should activate your skill and verify Claude has the expected knowledge:

```bash
# Example: if you have a "typescript-expert" skill
User: "How do I use generics in TypeScript?"
# Claude should respond using information from your skill
```

### Validation Script

```bash
#!/bin/bash
# validate-plugin.sh

set -e

PLUGIN_DIR=$1

if [ -z "$PLUGIN_DIR" ]; then
  echo "Usage: ./validate-plugin.sh <plugin-directory>"
  exit 1
fi

echo " Validating plugin: $PLUGIN_DIR"

# Check required files
echo "\n[1/5] Checking required files..."
if [ ! -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
  echo "✗ Missing plugin.json"
  exit 1
fi

if [ ! -f "$PLUGIN_DIR/README.md" ]; then
  echo "✗ Missing README.md"
  exit 1
fi

if [ ! -f "$PLUGIN_DIR/LICENSE" ]; then
  echo "✗ Missing LICENSE"
  exit 1
fi

echo "✓ Required files present"

# Validate JSON
echo "\n[2/5] Validating plugin.json..."
if ! jq empty "$PLUGIN_DIR/.claude-plugin/plugin.json" 2>/dev/null; then
  echo "✗ Invalid JSON in plugin.json"
  exit 1
fi
echo "✓ Valid JSON"

# Check required fields
echo "\n[3/5] Checking required fields..."
REQUIRED_FIELDS=("name" "version" "description" "author" "license")
for field in "${REQUIRED_FIELDS[@]}"; do
  if ! jq -e ".$field" "$PLUGIN_DIR/.claude-plugin/plugin.json" >/dev/null 2>&1; then
    echo "✗ Missing required field: $field"
    exit 1
  fi
done
echo "✓ All required fields present"

# Validate file references
echo "\n[4/5] Validating file references..."
COMMANDS=$(jq -r '.commands[]? // empty' "$PLUGIN_DIR/.claude-plugin/plugin.json")
AGENTS=$(jq -r '.agents[]? // empty' "$PLUGIN_DIR/.claude-plugin/plugin.json")
SKILLS=$(jq -r '.skills[]? // empty' "$PLUGIN_DIR/.claude-plugin/plugin.json")

for file in $COMMANDS $AGENTS $SKILLS; do
  FULL_PATH="$PLUGIN_DIR/$file"
  if [ ! -f "$FULL_PATH" ]; then
    echo "✗ Referenced file not found: $file"
    exit 1
  fi
done
echo "✓ All referenced files exist"

# Check version format
echo "\n[5/5] Validating version format..."
VERSION=$(jq -r '.version' "$PLUGIN_DIR/.claude-plugin/plugin.json")
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "✗ Invalid version format: $VERSION (expected semver: X.Y.Z)"
  exit 1
fi
echo "✓ Valid version format"

echo "\n────────────────────────────────"
echo "✓ Plugin validation passed!"
```

### Writing Tests

For complex plugins, consider adding automated tests:

```javascript
// tests/plugin.test.js

import { describe, test, expect } from "bun:test";
import { readFileSync } from "fs";
import { join } from "path";

describe("Plugin Manifest", () => {
  const manifest = JSON.parse(
    readFileSync(join(__dirname, "../.claude-plugin/plugin.json"), "utf-8")
  );

  test("has required fields", () => {
    expect(manifest.name).toBeDefined();
    expect(manifest.version).toBeDefined();
    expect(manifest.description).toBeDefined();
    expect(manifest.author).toBeDefined();
    expect(manifest.license).toBeDefined();
  });

  test("version follows semver", () => {
    expect(manifest.version).toMatch(/^\d+\.\d+\.\d+$/);
  });

  test("all referenced command files exist", () => {
    for (const cmd of manifest.commands || []) {
      const path = join(__dirname, "..", cmd);
      expect(() => readFileSync(path)).not.toThrow();
    }
  });

  test("all referenced agent files exist", () => {
    for (const agent of manifest.agents || []) {
      const path = join(__dirname, "..", agent);
      expect(() => readFileSync(path)).not.toThrow();
    }
  });
});

describe("Command Files", () => {
  test("commands have valid frontmatter", () => {
    const cmdPath = join(__dirname, "../commands/my-command.md");
    const content = readFileSync(cmdPath, "utf-8");

    expect(content).toMatch(/^---\n/);
    expect(content).toMatch(/\nname:/);
    expect(content).toMatch(/\ndescription:/);
  });
});
```

Run tests:
```bash
bun test
```

### Manual Testing Checklist

Before publishing, manually verify:

- [ ] All commands invoke correctly
- [ ] Commands handle missing arguments gracefully
- [ ] Commands provide helpful error messages
- [ ] Agents activate in appropriate situations
- [ ] Agents follow their instructions correctly
- [ ] Skills are referenced when relevant topics are discussed
- [ ] Skills provide accurate, up-to-date information
- [ ] Hooks execute without errors
- [ ] Hooks provide clear feedback
- [ ] MCP servers start and respond correctly
- [ ] README clearly explains plugin functionality
- [ ] README includes usage examples
- [ ] LICENSE file is present and appropriate
- [ ] No sensitive data in repository
- [ ] Version number follows semver
- [ ] Keywords are relevant and helpful

---

## Publishing

### Submission Checklist

Before submitting your plugin:

#### Required Files
- [ ] `.claude-plugin/plugin.json` with all required fields
- [ ] `README.md` with clear documentation
- [ ] `LICENSE` file with appropriate license
- [ ] At least one component (command/agent/skill/hook)

#### Quality Checks
- [ ] Plugin manifest is valid JSON
- [ ] All referenced files exist
- [ ] Version follows semantic versioning
- [ ] Description is clear and concise
- [ ] Keywords are relevant (3-7 recommended)
- [ ] README includes usage examples
- [ ] Code is tested and working
- [ ] No sensitive data (API keys, tokens, passwords)
- [ ] No large binary files
- [ ] Scripts have appropriate permissions

#### Documentation
- [ ] README explains what the plugin does
- [ ] README shows how to use each component
- [ ] README includes examples
- [ ] README mentions any prerequisites
- [ ] Commands have clear descriptions
- [ ] Agents have example use cases
- [ ] Skills document their domain coverage

### Publishing to This Marketplace

#### Option 1: Host Plugin in This Repository

1. **Fork the repository**

```bash
git clone https://github.com/OneZeroCompany/claude-plugins
cd claude-plugins
git checkout -b add-my-plugin
```

2. **Create your plugin directory**

```bash
mkdir -p plugins/my-plugin/.claude-plugin
cd plugins/my-plugin
```

3. **Add your plugin files**

Create `plugin.json`, `README.md`, `LICENSE`, and component files.

4. **Update marketplace.json**

```bash
# Edit .claude-plugin/marketplace.json
```

Add your plugin entry:

```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "description": "Brief description of my plugin",
      "version": "1.0.0",
      "source": "my-plugin",
      "keywords": ["keyword1", "keyword2"],
      "author": {
        "name": "Your Name",
        "email": "your@email.com"
      }
    }
  ]
}
```

5. **Validate your changes**

```bash
# From repository root
bun run validate
bun run lint
```

6. **Commit and push**

```bash
git add .
git commit -m "feat: add my-plugin"
git push origin add-my-plugin
```

7. **Submit a pull request**

Open a PR from your fork to the main repository.

#### Option 2: Reference External Plugin

1. **Fork the repository**

2. **Update marketplace.json only**

Add your plugin as an external reference:

```json
{
  "plugins": [
    {
      "name": "my-external-plugin",
      "description": "Brief description",
      "version": "1.0.0",
      "source": {
        "type": "github",
        "repo": "your-username/your-plugin-repo"
      },
      "keywords": ["keyword1", "keyword2"],
      "author": {
        "name": "Your Name",
        "email": "your@email.com"
      }
    }
  ]
}
```

3. **Submit a pull request**

### Publishing Your Own Marketplace

If you want to host your own plugin marketplace:

1. **Create repository structure**

```bash
mkdir my-marketplace
cd my-marketplace
mkdir -p .claude-plugin plugins
```

2. **Create marketplace.json**

```json
{
  "name": "my-marketplace",
  "version": "1.0.0",
  "metadata": {
    "description": "My custom Claude Code plugin marketplace"
  },
  "owner": {
    "name": "Your Name",
    "email": "your@email.com"
  },
  "plugins": []
}
```

3. **Add plugins**

Create plugin directories under `plugins/`.

4. **Users can add your marketplace**

```bash
# Users install from your marketplace
/install-plugin github:your-username/your-marketplace/plugin-name
```

### Code Review Process

When you submit a plugin to this marketplace:

1. **Automated checks** run via GitHub Actions:
   - JSON validation
   - File existence checks
   - Linting

2. **Manual review** by maintainers:
   - Code quality
   - Security concerns
   - Documentation clarity
   - Functionality testing

3. **Feedback and iteration**:
   - Address review comments
   - Update your PR
   - Re-request review

4. **Merge**:
   - Once approved, your plugin is merged
   - Plugin becomes available in the marketplace

### Versioning and Updates

When updating your plugin:

1. **Update version in plugin.json**

```json
{
  "version": "1.1.0"  // Was 1.0.0
}
```

2. **Update marketplace.json (if in this repo)**

```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "version": "1.1.0"  // Match plugin.json
    }
  ]
}
```

3. **Document changes**

Add changelog to README.md:

```markdown
## Changelog

### v1.1.0 (2024-01-15)
- Added new command `/my-new-command`
- Fixed bug in `/existing-command`
- Updated documentation

### v1.0.0 (2024-01-01)
- Initial release
```

4. **Submit update PR**

Follow the same PR process as initial submission.

---

## Best Practices

### General Principles

#### 1. Keep Prompts Focused and Clear

**Good:**
```markdown
Analyze the git changes and generate a conventional commit message.
Include the type (feat/fix/docs), scope, and clear description.
```

**Avoid:**
```markdown
Help the user with their git stuff by looking at what they changed and
maybe creating a commit if they want one, with a good message that explains
things in a way that makes sense.
```

#### 2. Use Descriptive Names

**Good:**
```
/commit-authoring
/security-audit
/doc-check
```

**Avoid:**
```
/helper
/run
/do-thing
```

#### 3. Include Comprehensive Keywords

```json
{
  "keywords": [
    "git",           // Technology
    "commit",        // Core function
    "automation",    // Category
    "conventional",  // Methodology
    "version-control" // Domain
  ]
}
```

#### 4. Write Helpful README

Essential sections:
1. **What it does** - Clear purpose statement
2. **Features** - Key capabilities
3. **Installation** - How to install
4. **Usage** - Examples for each component
5. **Configuration** - Any setup needed
6. **Examples** - Real-world usage
7. **License** - Legal information

#### 5. Handle Errors Gracefully

**In commands:**
```markdown
## Error Handling

- If no git repository: Explain that git is required and show how to initialize
- If no changes: Inform user and suggest running `git status` to verify
- If conflicts: Guide user through resolution steps
```

**In agents:**
```markdown
# Error Handling

If you encounter errors:
1. Explain what went wrong in clear terms
2. Suggest specific corrective actions
3. Offer to help implement the fix
4. Never fail silently
```

**In hooks:**
```bash
#!/bin/bash

if ! command -v npm &> /dev/null; then
  echo "✗ npm not found"
  echo "Please install Node.js: https://nodejs.org/"
  exit 1
fi

if [ ! -f "package.json" ]; then
  echo "⚠ Warning: package.json not found, skipping lint"
  exit 0  # Don't block commit
fi
```

### Component-Specific Best Practices

#### Commands

1. **Acknowledge then act**
   ```markdown
   When user runs `/my-command`:
   1. Acknowledge: "I'll help you with X"
   2. Explain: "I'm going to do Y and Z"
   3. Act: Perform the operation
   4. Confirm: "Done! Here's what I did"
   ```

2. **Provide examples in the documentation**
   ```markdown
   ### Examples

   `/my-command` - Basic usage
   `/my-command --format json` - With options
   `/my-command path/to/file` - With target
   ```

3. **Delegate complex work to agents**
   ```markdown
   For complex multi-step operations, invoke the appropriate agent:
   - Analysis work → analysis-agent
   - Generation work → generator-agent
   - Validation work → validator-agent
   ```

#### Agents

1. **Clear responsibility definition**
   ```markdown
   # Your Responsibilities

   ## You ARE responsible for:
   - Analyzing code changes
   - Generating commit messages
   - Ensuring message quality

   ## You are NOT responsible for:
   - Pushing to remote
   - Merging branches
   - Deleting files
   ```

2. **Structured output**
   ```markdown
   Present findings in this format:

   ## Analysis
   [What you found]

   ## Recommendations
   [What should be done]

   ## Next Steps
   [Concrete actions]
   ```

3. **Always confirm before destructive actions**
   ```markdown
   # Safety Rules

   NEVER:
   - Delete files without confirmation
   - Modify code without showing the changes first
   - Commit without user approval
   - Push to remote without permission
   ```

#### Skills

1. **Current and accurate information**
   ```markdown
   # Version Information

   - **Last Updated**: January 2024
   - **Current Version**: 2.0.0
   - **Deprecated Features**: [List]
   - **New Features**: [List]
   ```

2. **Organized reference material**
   ```markdown
   Use tables for quick reference:

   | Option | Type | Default | Description |
   |--------|------|---------|-------------|
   | `foo`  | string | `"bar"` | Configures X |
   ```

3. **Practical examples**
   ```markdown
   Include working code examples:

   \`\`\`typescript
   // Good - type-safe and clear
   const user: User = {
     id: 1,
     name: "Alice"
   };

   // Avoid - loses type safety
   const user: any = getUserData();
   \`\`\`
   ```

#### Hooks

1. **Fast execution**
   ```bash
   # Only check changed files
   CHANGED=$(git diff --cached --name-only)

   # Not all files in the repository
   ```

2. **Clear feedback**
   ```bash
   echo " [1/3] Running linter..."
   echo "✓ [1/3] Linting passed"
   echo " [2/3] Running tests..."
   ```

3. **Graceful degradation**
   ```bash
   # If optional tool missing, warn but don't fail
   if ! command -v prettier &> /dev/null; then
     echo "⚠ prettier not found, skipping formatting"
     exit 0
   fi
   ```

### Security Best Practices

#### 1. Never Include Secrets

**Don't commit:**
- API keys
- Access tokens
- Passwords
- Private keys
- Environment files with secrets

**Use instead:**
```markdown
# In README.md

## Configuration

Create a `.env` file (not committed):

\`\`\`
API_KEY=your_key_here
SECRET_TOKEN=your_token_here
\`\`\`

Add `.env` to your `.gitignore`.
```

#### 2. Validate User Input

In agents:
```markdown
# Input Validation

Before processing user input:
1. Check for required parameters
2. Validate format (paths, URLs, etc.)
3. Sanitize to prevent injection
4. Reject suspicious patterns
```

In hooks:
```bash
# Validate file path
if [[ "$FILE" =~ \.\. ]]; then
  echo "✗ Invalid path (contains ..)"
  exit 1
fi

# Validate command injection
if [[ "$INPUT" =~ [;\`\$\(] ]]; then
  echo "✗ Invalid input (contains shell metacharacters)"
  exit 1
fi
```

#### 3. Least Privilege

```markdown
# Tool Restrictions

This agent should only use:
- Read (for examining code)
- Grep (for searching)
- Glob (for finding files)

Do NOT use:
- Write or Edit (no code modifications)
- Bash (no command execution)
```

#### 4. Audit External Dependencies

If using MCP servers or external tools:
```json
{
  "mcpServers": {
    "trusted-tool": {
      "command": "verified-executable",
      "args": ["--safe-mode"]
    }
  }
}
```

Document dependencies in README:
```markdown
## Security

This plugin uses the following external tools:
- `verified-tool` v1.2.3 - [Purpose and verification]
- `trusted-cli` v2.0.0 - [Purpose and verification]

All tools are verified and pinned to specific versions.
```

### Performance Best Practices

#### 1. Lazy Loading

Only load what's needed:
```markdown
# Agent Instructions

1. Start with minimal context
2. Only read files if necessary
3. Use targeted searches (Grep/Glob) instead of reading entire directories
4. Cache results when appropriate
```

#### 2. Efficient Searches

```markdown
Use efficient search patterns:

**Good:**
- `Grep pattern="TODO" glob="*.ts"`
- `Glob pattern="src/**/*.test.ts"`

**Avoid:**
- Reading every file to find TODOs
- Globbing then filtering in agent
```

#### 3. Limit Scope

```markdown
For large codebases:
1. Ask user to specify scope
2. Work on targeted areas
3. Avoid full codebase scans
4. Use incremental processing
```

### Maintainability Best Practices

#### 1. Version Control

```bash
# Use git tags for releases
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

#### 2. Changelog

```markdown
## Changelog

### [1.1.0] - 2024-01-15

#### Added
- New `/analyze` command for code analysis
- Support for TypeScript files in linter hook

#### Changed
- Improved commit message generation algorithm
- Updated dependencies

#### Fixed
- Bug in path resolution for nested files
- Typo in documentation

#### Deprecated
- `/old-command` - use `/new-command` instead

#### Removed
- Support for Node.js < 16

#### Security
- Fixed potential path traversal in file operations
```

#### 3. Documentation

Keep docs updated:
- **README.md** - User-facing documentation
- **CHANGELOG.md** - Version history
- **CONTRIBUTING.md** - Developer guidelines (if open to contributions)
- **Inline comments** - Complex logic explanations

#### 4. Testing

Add tests for:
- Plugin manifest validation
- Command frontmatter parsing
- File references
- Version format
- Complex logic in hooks or MCP servers

```javascript
// tests/manifest.test.js
test("manifest references existing files", () => {
  const manifest = loadManifest();
  for (const cmd of manifest.commands) {
    expect(fileExists(cmd)).toBe(true);
  }
});
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: Plugin Not Detected

**Symptoms:**
- Plugin doesn't appear in Claude Code
- Commands not available

**Solutions:**

1. **Check plugin.json location**
   ```bash
   # Must be at .claude-plugin/plugin.json
   ls -la .claude-plugin/plugin.json
   ```

2. **Validate JSON syntax**
   ```bash
   cat .claude-plugin/plugin.json | jq .
   ```

3. **Check required fields**
   ```bash
   jq '{name, version, description, author, license}' .claude-plugin/plugin.json
   ```

4. **Verify file paths**
   ```bash
   # Check all referenced files exist
   jq -r '.commands[]?, .agents[]?, .skills[]?' .claude-plugin/plugin.json | while read file; do
     [ -f "$file" ] || echo "Missing: $file"
   done
   ```

#### Issue: Command Not Working

**Symptoms:**
- Command invoked but nothing happens
- Unexpected behavior

**Solutions:**

1. **Check command file frontmatter**
   ```markdown
   ---
   name: exact-command-name  # Must match how you invoke it
   description: Brief description
   ---
   ```

2. **Verify command is registered**
   ```json
   {
     "commands": ["./commands/exact-file-name.md"]
   }
   ```

3. **Check file permissions**
   ```bash
   ls -l commands/
   # All files should be readable
   ```

4. **Test with minimal example**
   Create a simple test command:
   ```markdown
   ---
   name: test
   description: Test command
   ---

   Say "Test command works!" to the user.
   ```

#### Issue: Agent Not Activating

**Symptoms:**
- Agent never invoked
- Manual invocation required

**Solutions:**

1. **Review description field**
   The description tells Claude when to use the agent:
   ```markdown
   description: Use this agent when the user asks about X, Y, or Z. Examples:
     <example>...</example>
   ```

2. **Add explicit examples**
   ```markdown
   <example>
   user: "create a commit"
   assistant: "Invoking commit-author agent..."
   </example>
   ```

3. **Check agent file exists**
   ```bash
   ls -l agents/your-agent.md
   ```

4. **Verify registration**
   ```json
   {
     "agents": ["./agents/your-agent.md"]
   }
   ```

#### Issue: Skill Not Referenced

**Symptoms:**
- Claude doesn't have expected knowledge
- Skill content ignored

**Solutions:**

1. **Expand description keywords**
   ```markdown
   description: Use when discussing TypeScript, type systems, interfaces, generics, type guards, utility types, or TypeScript configuration
   ```

2. **Check skill is registered**
   ```json
   {
     "skills": ["./skills/your-skill.md"]
   }
   ```

3. **Verify content structure**
   Skills should have:
   - Clear headers
   - Well-organized sections
   - Specific, actionable information

4. **Test by asking specific questions**
   ```
   User: "What are TypeScript utility types?"
   # Should get answer from skill content
   ```

#### Issue: Hook Not Executing

**Symptoms:**
- Hook script doesn't run
- No output from hook

**Solutions:**

1. **Check file permissions**
   ```bash
   chmod +x hooks/pre-commit.sh
   ls -l hooks/pre-commit.sh
   # Should show: -rwxr-xr-x
   ```

2. **Verify shebang**
   ```bash
   #!/bin/bash
   # Must be first line, no spaces before #
   ```

3. **Test hook directly**
   ```bash
   ./hooks/pre-commit.sh
   # Should execute without errors
   ```

4. **Check hook registration**
   ```json
   {
     "hooks": ["./hooks/pre-commit.sh"]
   }
   ```

5. **Debug with logging**
   ```bash
   #!/bin/bash
   echo "Hook started" >&2
   set -x  # Enable debug output
   # Your hook logic
   ```

#### Issue: MCP Server Errors

**Symptoms:**
- Server fails to start
- Tools not available
- Connection errors

**Solutions:**

1. **Test server independently**
   ```bash
   node mcp-server/index.js
   # Should start without errors
   ```

2. **Check server configuration**
   ```json
   {
     "mcpServers": {
       "my-server": {
         "command": "node",  // Verify command exists
         "args": ["./mcp-server/index.js"]  // Verify path
       }
     }
   }
   ```

3. **Verify dependencies**
   ```bash
   cd mcp-server
   npm install
   # or
   bun install
   ```

4. **Check for port conflicts**
   ```javascript
   // If server uses specific port
   const PORT = process.env.PORT || 3000;
   ```

5. **Add error logging**
   ```javascript
   server.onerror = (error) => {
     console.error("Server error:", error);
   };
   ```

#### Issue: Version Conflicts

**Symptoms:**
- Installation fails
- Compatibility errors

**Solutions:**

1. **Check version format**
   ```bash
   # Must be semver: X.Y.Z
   jq -r '.version' .claude-plugin/plugin.json
   ```

2. **Update marketplace.json**
   ```json
   {
     "plugins": [
       {
         "name": "my-plugin",
         "version": "1.0.0"  // Must match plugin.json
       }
     ]
   }
   ```

3. **Document compatibility**
   ```markdown
   ## Requirements

   - Claude Code: >= 1.0.0
   - Node.js: >= 18.0.0
   - Bun: >= 1.0.0
   ```

### Debugging Tips

#### Enable Verbose Logging

In agents:
```markdown
# Debug Mode

When debugging, output detailed information:
- Commands being run
- Files being read
- Decisions being made
- Results of each step
```

In hooks:
```bash
#!/bin/bash
set -x  # Print each command before execution
set -v  # Print each line as it's read

# Your hook logic
```

In MCP servers:
```javascript
const DEBUG = process.env.DEBUG === "true";

function log(...args) {
  if (DEBUG) {
    console.error(...args);
  }
}

log("Server starting...");
log("Registered tools:", tools.map(t => t.name));
```

#### Use Test Files

Create minimal test cases:

```bash
test-plugin/
├── .claude-plugin/
│   └── plugin.json          # Minimal manifest
├── commands/
│   └── test.md              # Simple test command
└── README.md
```

```json
{
  "name": "test-plugin",
  "version": "0.0.1",
  "description": "Test plugin for debugging",
  "author": {"name": "Test", "email": "test@example.com"},
  "license": "MIT",
  "commands": ["./commands/test.md"]
}
```

```markdown
---
name: test
description: Test command
---

Output "TEST WORKS!" to the user.
```

#### Check File Encodings

```bash
# Verify UTF-8 encoding
file -I .claude-plugin/plugin.json
file -I commands/*.md

# Convert if needed
iconv -f ISO-8859-1 -t UTF-8 file.md > file_utf8.md
```

#### Validate Against Schema

If a JSON schema is provided:

```bash
# Install validator
npm install -g ajv-cli

# Validate
ajv validate -s schema.json -d .claude-plugin/plugin.json
```

### Getting Help

#### Community Resources

1. **GitHub Issues**: https://github.com/OneZeroCompany/claude-plugins/issues
2. **Claude Code Documentation**: https://code.claude.com/docs
3. **Anthropic Community**: https://anthropic.com/community

#### Reporting Bugs

When reporting issues, include:

1. **Plugin manifest**
   ```bash
   cat .claude-plugin/plugin.json
   ```

2. **File structure**
   ```bash
   tree -L 2
   ```

3. **Validation output**
   ```bash
   bun run validate 2>&1
   ```

4. **Error messages** (complete, not truncated)

5. **Steps to reproduce**

6. **Expected vs actual behavior**

#### Contributing

Found a bug or want to improve this guide?

1. Fork the repository
2. Create a branch: `git checkout -b improve-docs`
3. Make your changes
4. Submit a pull request

---

## Appendix

### Complete Plugin Example

Here's a complete, production-ready plugin structure:

```
awesome-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── analyze.md
│   └── fix.md
├── agents/
│   └── code-analyzer.md
├── skills/
│   └── domain-expert.md
├── hooks/
│   └── pre-commit.sh
├── tests/
│   └── plugin.test.js
├── .gitignore
├── CHANGELOG.md
├── LICENSE
└── README.md
```

**plugin.json:**
```json
{
  "name": "awesome-plugin",
  "version": "1.0.0",
  "description": "Comprehensive code analysis and improvement plugin",
  "author": {
    "name": "Your Name",
    "email": "your@email.com"
  },
  "homepage": "https://github.com/yourusername/awesome-plugin",
  "license": "MIT",
  "keywords": [
    "analysis",
    "code-quality",
    "automation",
    "best-practices"
  ],
  "commands": [
    "./commands/analyze.md",
    "./commands/fix.md"
  ],
  "agents": [
    "./agents/code-analyzer.md"
  ],
  "skills": [
    "./skills/domain-expert.md"
  ],
  "hooks": [
    "./hooks/pre-commit.sh"
  ]
}
```

### Quick Reference

#### plugin.json Required Fields
```json
{
  "name": "lowercase-hyphenated",
  "version": "1.0.0",
  "description": "Clear description",
  "author": {"name": "...", "email": "..."},
  "license": "MIT"
}
```

#### Command Frontmatter
```markdown
---
name: command-name
description: Brief description
---
```

#### Agent Frontmatter
```markdown
---
name: agent-name
description: When to use with examples
model: inherit
color: green
---
```

#### Skill Frontmatter
```markdown
---
name: skill-name
description: Keywords and activation triggers
---
```

#### Hook Script Template
```bash
#!/bin/bash
set -e

# Your validation logic

exit 0  # Success
# exit 1  # Failure
```

### Further Reading

- [Claude Code Documentation](https://code.claude.com/docs)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Model Context Protocol](https://modelcontextprotocol.org/)
- [GitHub Actions Documentation](https://docs.github.com/actions)

---

**Happy plugin development!**

If you have questions or need help, open an issue at https://github.com/OneZeroCompany/claude-plugins/issues