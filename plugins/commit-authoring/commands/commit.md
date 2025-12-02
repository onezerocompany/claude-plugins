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

### Example Usage

When the user runs `/commit`, immediately spawn the commit-author agent:

```
I'll analyze your changes and help create a commit. Let me hand this over to the commit-author agent.
```

Then invoke the commit-author agent.

### Notes

- The agent will handle all git operations
- Users can provide additional context by running `/commit [context]` - pass this context to the agent
- The agent will never commit without explicit user approval
