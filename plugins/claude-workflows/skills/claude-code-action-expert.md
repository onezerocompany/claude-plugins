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

Claude Code Action is a flexible GitHub automation platform that auto-detects execution mode based on workflow context. It supports:

- PR reviews and code analysis
- @claude mention responses
- Custom automations and scheduled tasks
- Issue triage and documentation sync

## Complete Input Reference

### Trigger Configuration

| Input | Description | Default |
|-------|-------------|---------|
| `trigger_phrase` | Phrase to look for in comments | `@claude` |
| `assignee_trigger` | Username that triggers when assigned | - |
| `label_trigger` | Label that triggers the action | `claude` |

### Branch Configuration

| Input | Description | Default |
|-------|-------------|---------|
| `base_branch` | Base branch for new branches | - |
| `branch_prefix` | Prefix for Claude-created branches | `claude/` |

### Security Configuration

| Input | Description | Default |
|-------|-------------|---------|
| `allowed_bots` | Comma-separated bot usernames, or `*` for all | `""` |
| `allowed_non_write_users` | Users allowed without write permissions | `""` |

### Claude Configuration

| Input | Description | Default |
|-------|-------------|---------|
| `prompt` | Instructions for Claude (enables automation mode) | `""` |
| `settings` | JSON string or path to settings file | `""` |
| `claude_args` | Additional CLI arguments | `""` |

### Authentication (choose one)

| Input | Description |
|-------|-------------|
| `anthropic_api_key` | Direct Anthropic API key |
| `claude_code_oauth_token` | OAuth token for Pro/Max users |
| `github_token` | Custom GitHub token (optional) |

### Cloud Provider Configuration

| Input | Description | Default |
|-------|-------------|---------|
| `use_bedrock` | Use Amazon Bedrock with OIDC | `false` |
| `use_vertex` | Use Google Vertex AI with OIDC | `false` |
| `use_foundry` | Use Microsoft Foundry with OIDC | `false` |

### Advanced Options

| Input | Description | Default |
|-------|-------------|---------|
| `use_sticky_comment` | Single comment for all responses | `false` |
| `use_commit_signing` | Enable GitHub commit signing | `false` |
| `bot_id` | GitHub user ID for git operations | `41898282` |
| `bot_name` | GitHub username for git operations | `claude[bot]` |
| `track_progress` | Force tracking comments | `false` |
| `show_full_output` | Show full JSON output | `false` |
| `plugins` | Newline-separated plugin names | `""` |
| `plugin_marketplaces` | Plugin marketplace Git URLs | `""` |
| `additional_permissions` | Extra GitHub permissions | `""` |
| `path_to_claude_code_executable` | Custom Claude Code binary | `""` |
| `path_to_bun_executable` | Custom Bun runtime | `""` |

### Outputs

| Output | Description |
|--------|-------------|
| `execution_file` | Path to execution output file |
| `branch_name` | Branch created by Claude |
| `github_token` | GitHub token used by action |
| `structured_output` | JSON output when using `--json-schema` |

## Authentication Methods

### 1. Anthropic API Key (Recommended)

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 2. Claude Code OAuth Token

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
```

### 3. AWS Bedrock (OIDC)

```yaml
permissions:
  id-token: write
  contents: read
  pull-requests: write
  issues: write

- uses: anthropics/claude-code-action@v1
  with:
    use_bedrock: true
    claude_args: --model anthropic.claude-4-0-sonnet-20250805-v1:0
  env:
    AWS_REGION: us-east-1
    AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
```

### 4. Google Vertex AI (OIDC)

```yaml
permissions:
  id-token: write
  contents: read
  pull-requests: write
  issues: write

- uses: anthropics/claude-code-action@v1
  with:
    use_vertex: true
    claude_args: --model claude-4-0-sonnet@20250805
  env:
    GOOGLE_CLOUD_PROJECT: your-project-id
    GOOGLE_CLOUD_REGION: us-central1
```

### 5. Microsoft Foundry (OIDC)

```yaml
permissions:
  id-token: write
  contents: read
  pull-requests: write
  issues: write

- uses: anthropics/claude-code-action@v1
  with:
    use_foundry: true
    claude_args: --model claude-sonnet-4-5
  env:
    ANTHROPIC_FOUNDRY_BASE_URL: https://your-resource.azure.com
```

## Execution Modes

### Interactive Mode (Tag Mode)

Activated by @claude mentions, issue assignments, or labels. Creates tracking comments with progress checkboxes.

```yaml
# Minimal interactive setup - responds to @claude mentions
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Automation Mode (Agent Mode)

Activated when `prompt` input is provided. Runs directly without tracking comments by default.

```yaml
# Automation mode - runs immediately with specified prompt
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    prompt: |
      Review this PR for security vulnerabilities.
      Focus on OWASP Top 10 issues.
```

## Security Best Practices

### 1. Credential Storage

**NEVER hardcode credentials in workflow files!**

```yaml
# CORRECT - Using secrets
anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}

# WRONG - Never do this
anthropic_api_key: sk-ant-xxxxx
```

### 2. Permission Restrictions

Always use minimal required permissions:

```yaml
permissions:
  contents: read      # Minimum for reading code
  pull-requests: write # For PR comments
  issues: write       # For issue comments
  # Only add more if specifically needed:
  # actions: read     # To view CI results
  # id-token: write   # For OIDC auth
```

### 3. Access Control

Only users with write permissions can trigger by default:

```yaml
# Restrict bot access (default is none)
allowed_bots: ""

# Only allow specific bots if needed
allowed_bots: "dependabot[bot],renovate[bot]"

# DANGEROUS - Allow all bots (not recommended)
allowed_bots: "*"
```

### 4. Non-Write User Access

Use with extreme caution - introduces significant risk:

```yaml
# Only works with github_token input
# Restrict to minimal permission workflows only
allowed_non_write_users: "external-reviewer"
```

### 5. Tool Restrictions

Limit Claude's tool access to what's necessary:

```yaml
claude_args: |
  --allowedTools "Read,Write,Edit,Bash(npm test),Bash(npm run lint)"
  --disallowedTools "Bash(rm:*),Bash(curl:*)"
```

### 6. Debug Mode Warning

Full output is automatically enabled in GitHub Actions debug mode. This can expose sensitive data in public repos!

```yaml
# Keep disabled by default
show_full_output: false
```

### 7. Commit Signing

Enable for verifiable commit trails:

```yaml
use_commit_signing: true
```

### 8. Input Sanitization

The action removes malicious content (HTML comments, invisible characters, etc.), but always review content from untrusted sources.

## Workflow Templates

### Basic Interactive Workflow

```yaml
name: Claude Code

on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  pull_request_review:
    types: [submitted]
  issues:
    types: [opened, assigned, labeled]

permissions:
  contents: read
  pull-requests: write
  issues: write

jobs:
  claude:
    if: |
      (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review' && contains(github.event.review.body, '@claude')) ||
      (github.event_name == 'issues' && (
        contains(github.event.issue.body, '@claude') ||
        contains(github.event.issue.title, '@claude') ||
        github.event.assignee.login == 'claude' ||
        github.event.label.name == 'claude'
      ))
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 1

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Automated PR Review

```yaml
name: Claude PR Review

on:
  pull_request:
    types: [opened, synchronize]

permissions:
  contents: read
  pull-requests: write

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Review this PR thoroughly. Check for:
            1. Code quality and best practices
            2. Potential bugs or edge cases
            3. Security vulnerabilities
            4. Performance implications
            5. Test coverage

            Provide constructive feedback with specific suggestions.
          claude_args: --max-turns 10
```

### Security-Focused Review

```yaml
name: Claude Security Review

on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - 'src/auth/**'
      - 'src/api/**'
      - '**/*auth*'
      - '**/*security*'

permissions:
  contents: read
  pull-requests: write

jobs:
  security-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Perform a security-focused review of this PR.

            Check for OWASP Top 10 vulnerabilities:
            - Injection flaws (SQL, NoSQL, Command, LDAP)
            - Broken authentication/session management
            - Sensitive data exposure
            - XML External Entities (XXE)
            - Broken access control
            - Security misconfiguration
            - Cross-Site Scripting (XSS)
            - Insecure deserialization
            - Using components with known vulnerabilities
            - Insufficient logging & monitoring

            Rate each finding: CRITICAL, HIGH, MEDIUM, or LOW.
            Provide specific remediation guidance.
          claude_args: |
            --max-turns 15
            --allowedTools "Read,Grep,Glob,mcp__github_inline_comment__create_inline_comment"
```

### Issue Triage Automation

```yaml
name: Claude Issue Triage

on:
  issues:
    types: [opened]

permissions:
  contents: read
  issues: write

jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Triage this new issue:

            1. Categorize: bug, feature, question, documentation
            2. Assess priority: critical, high, medium, low
            3. Identify affected components
            4. Suggest relevant labels
            5. Add helpful initial response

            Be welcoming to contributors. If more info is needed,
            ask specific clarifying questions.
          claude_args: |
            --max-turns 5
            --allowedTools "Bash(gh issue:*),Read"
```

### Scheduled Maintenance

```yaml
name: Claude Weekly Maintenance

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9 AM
  workflow_dispatch:  # Manual trigger

permissions:
  contents: write
  pull-requests: write
  issues: write

jobs:
  maintenance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Perform weekly maintenance tasks:

            1. Check for outdated dependencies
            2. Review open issues older than 30 days
            3. Identify stale PRs needing attention
            4. Check for TODO/FIXME comments in code
            5. Create a summary issue with findings

            Do not make changes automatically - create issues
            or PRs for review instead.
          claude_args: |
            --max-turns 20
            --allowedTools "Read,Grep,Glob,Bash(gh issue:*),Bash(gh pr:*),Bash(npm outdated)"
```

### External Contributor Review

```yaml
name: Claude External Contributor Review

on:
  pull_request:
    types: [opened, synchronize]

permissions:
  contents: read
  pull-requests: write

jobs:
  review:
    if: github.event.pull_request.author_association == 'FIRST_TIME_CONTRIBUTOR'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Welcome this first-time contributor!

            Review their PR with extra care:
            1. Check code follows project conventions
            2. Ensure tests are included
            3. Verify documentation is updated
            4. Look for security issues
            5. Provide helpful, constructive feedback

            Be encouraging and offer to help if needed.
          claude_args: --max-turns 10
```

### With CI Results Access

```yaml
name: Claude with CI Access

on:
  issue_comment:
    types: [created]

permissions:
  contents: read
  pull-requests: write
  issues: write
  actions: read  # Required for CI results access

jobs:
  claude:
    if: contains(github.event.comment.body, '@claude')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          additional_permissions: "actions: read"
```

## Claude Args Reference

Common CLI arguments passed via `claude_args`:

```yaml
claude_args: |
  --model claude-4-0-sonnet-20250805
  --max-turns 20
  --system-prompt "You are a strict code reviewer..."
  --allowedTools "Read,Write,Edit,Bash(npm:*)"
  --disallowedTools "Bash(rm:*)"
  --mcp-config '{"servers": {...}}'
```

### Model Selection

- Anthropic: `claude-4-0-sonnet-20250805`
- Bedrock: `anthropic.claude-4-0-sonnet-20250805-v1:0`
- Vertex: `claude-4-0-sonnet@20250805`
- Foundry: `claude-sonnet-4-5`

### Tool Restrictions

```yaml
# Allow specific tools
--allowedTools "Read,Write,Edit,Grep,Glob"

# Allow bash with patterns
--allowedTools "Bash(npm:*),Bash(git status),Bash(gh pr:*)"

# Disallow specific tools
--disallowedTools "Bash(rm:*),Bash(curl:*),Bash(wget:*)"
```

## Settings JSON Configuration

For complex configurations, use a settings file:

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    settings: |
      {
        "env": {
          "NODE_ENV": "test",
          "CUSTOM_VAR": "value"
        },
        "permissions": {
          "allow": ["Read", "Write", "Edit"],
          "deny": ["Bash(rm:*)"]
        }
      }
```

## Capabilities & Limitations

### What Claude CAN Do

- Answer code questions and explain functionality
- Analyze PRs and provide feedback
- Make code modifications and create commits
- Create branches and link to PR creation pages
- View CI/CD results (with proper permissions)
- Add inline comments on PR diffs
- Update a single tracking comment with progress

### What Claude CANNOT Do

- Formally approve or review PRs (security restriction)
- Execute arbitrary bash without explicit allowance
- Access other repositories (sandboxed to current repo)
- Force push, rebase, or destructive git operations
- Modify workflow files (intentional security restriction)
- Create PRs directly (provides pre-filled links instead)

## Migration from v0.x

If upgrading from beta/v0.x:

| Old Input | New Approach |
|-----------|--------------|
| `mode` | Auto-detected from context |
| `direct_prompt` | Use `prompt` |
| `custom_instructions` | `claude_args: --system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON with env object |
| `mcp_config` | `claude_args: --mcp-config` |
| `timeout_minutes` | Job-level `timeout-minutes` |

## Troubleshooting

### Common Issues

1. **"403 Resource not accessible"** - Ensure proper permissions are set
2. **OIDC errors** - Add `id-token: write` permission
3. **Claude won't update workflows** - By design, no workflow write access
4. **Comments not as claude[bot]** - Remove custom `github_token` input
5. **Bash commands fail** - Enable specific commands via `--allowedTools`
6. **@claude trigger variations don't work** - Only exact `@claude` works (word boundary)

### Debug Tips

- Check GitHub Action logs for execution traces
- Use `show_full_output: true` in private repos only
- Verify secrets are properly configured
- Test on separate branches first
