# Claude Workflows Plugin

Expert guidance for creating secure, production-ready GitHub workflows using Claude Code Action with up-to-date patterns and best practices.

## Features

- **Skill**: Comprehensive knowledge of `anthropics/claude-code-action@v1` including all configuration options, authentication methods, and security best practices
- **Command**: `/generate-workflow` - Interactive workflow generator
- **Agent**: `workflow-expert` - Autonomous workflow creation and troubleshooting

## Installation

```bash
/plugin install claude-workflows@claude-plugins
```

## Usage

### Using the Skill

The skill is automatically loaded when you ask about:
- Creating GitHub workflows with Claude
- claude-code-action configuration
- PR review automation
- Issue triage workflows
- Security best practices for CI/CD

### Using the Command

```bash
/generate-workflow
```

This starts an interactive session to create a customized workflow based on your needs.

### Using the Agent

The `workflow-expert` agent is automatically invoked when you need help with:
- Creating new Claude workflows from scratch
- Reviewing existing workflows for security issues
- Troubleshooting broken configurations
- Understanding configuration options

## Covered Topics

### Authentication Methods
- Anthropic API Key (direct)
- Claude Code OAuth Token
- AWS Bedrock (OIDC)
- Google Vertex AI (OIDC)
- Microsoft Foundry (OIDC)

### Workflow Types
- Interactive (@claude mentions)
- Automated PR reviews
- Security-focused reviews
- Issue triage
- Scheduled maintenance
- Custom automations

### Security Best Practices
- Minimal permission configuration
- Secret management
- Tool restrictions
- Commit signing
- Bot access controls

## Version Support

This plugin provides guidance for `anthropics/claude-code-action@v1` (current stable version v1.0.x).

## License

MIT License - see [LICENSE](LICENSE) for details.
