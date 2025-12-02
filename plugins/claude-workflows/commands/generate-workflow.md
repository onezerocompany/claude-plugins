---
name: generate-workflow
description: Generate a secure, production-ready GitHub workflow using Claude Code Action based on your requirements
---

# Generate Claude Workflow Command

Generate a secure, production-ready GitHub workflow using Claude Code Action.

## Instructions

You are helping the user create a GitHub Actions workflow that uses claude-code-action. First, load the `claude-code-action-expert` skill to access comprehensive knowledge about the latest version, configuration options, and security best practices.

### Process

1. **Load Expertise**: Invoke the `claude-code-action-expert` skill to ensure you have current knowledge

2. **Gather Requirements**: Ask the user what type of workflow they need:
   - Interactive (responds to @claude mentions)
   - Automated PR review
   - Security-focused review
   - Issue triage
   - Scheduled maintenance
   - Custom automation

3. **Determine Configuration**:
   - Authentication method (API key, OAuth, Bedrock, Vertex, Foundry)
   - Required permissions
   - Tool restrictions
   - Trigger conditions
   - Any custom prompts or system prompts

4. **Generate Workflow**: Create a secure workflow following these principles:
   - Always use `anthropics/claude-code-action@v1`
   - Use minimal required permissions
   - Never hardcode secrets
   - Include appropriate comments
   - Follow security best practices

5. **Review & Explain**: Walk through the generated workflow explaining:
   - Why each permission is needed
   - Security considerations
   - How to configure required secrets
   - Any customization options

### Example Usage

When the user runs `/generate-workflow`, start by asking:

```
I'll help you create a secure GitHub workflow using Claude Code Action.

What type of workflow do you need?

1. **Interactive** - Responds to @claude mentions in issues/PRs
2. **PR Review** - Automatically reviews all PRs
3. **Security Review** - Security-focused review on sensitive files
4. **Issue Triage** - Automatically categorize and respond to new issues
5. **Scheduled Task** - Run maintenance or checks on a schedule
6. **Custom** - I'll describe what I need

Which would you like? (Enter a number or describe your use case)
```

### Important Guidelines

- Always recommend `@v1` version, never `@beta` or specific patch versions
- Warn about security implications of `allowed_bots: "*"` or `allowed_non_write_users`
- Suggest `use_commit_signing: true` for verifiable commits
- Recommend tool restrictions when possible
- Explain the principle of least privilege for permissions
- Check if user needs CI results access (`actions: read`)
