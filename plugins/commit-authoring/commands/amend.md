---
name: amend
description: Intelligently amend the last commit with new changes and optionally update the commit message
---

# Amend Command

Amend the last commit with new changes and optionally regenerate the commit message using AI to reflect both the original and new changes.

## Instructions

You are helping the user amend their last git commit. Use the amend-author agent to analyze the changes and handle the amendment process safely.

### Process

1. **Activate the Agent**: Invoke the `amend-author` agent to handle the amend process
2. **Agent Will**:
   - Check if the last commit has been pushed (warn about force push implications)
   - Analyze the original commit (HEAD) and any new staged/unstaged changes
   - Determine if the commit message should be updated based on change significance
   - Generate a new commit message that incorporates both original and new changes
   - Show before/after comparison of the commit message
   - Ask for user approval before amending

### Example Usage

When the user runs `/amend`, immediately spawn the amend-author agent:

```
I'll help you amend your last commit. Let me analyze the changes and handle this safely.
```

Then invoke the amend-author agent.

### Flags and Context

- Users can run `/amend --no-edit` to keep the original message (useful for forgotten files)
- Users can provide context: `/amend fixing the typo` - pass this context to the agent
- The `--no-edit` flag tells the agent to skip message regeneration

### Notes

- The agent will handle all git operations and safety checks
- The agent will warn if HEAD commit has been pushed to remote
- The agent will never amend without explicit user approval
- All safety checks are performed before any git operations
