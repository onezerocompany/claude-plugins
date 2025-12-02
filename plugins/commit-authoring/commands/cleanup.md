---
name: cleanup
description: Clean up the git staging area by removing unwanted or accidentally staged files
---

# Cleanup Command

Clean up the git staging area by removing unwanted or accidentally staged files.

## Instructions

Help the user clean up their git staging area by identifying and removing files that shouldn't be committed.

### Process

1. **Check Status**: Run `git status` to see what's staged
2. **Identify Issues**: Look for:
   - Build artifacts (dist/, build/, node_modules/, etc.)
   - IDE files (.vscode/, .idea/, *.swp, etc.)
   - OS files (.DS_Store, Thumbs.db, etc.)
   - Temporary files (*.tmp, *.log, *.cache, etc.)
   - Sensitive files (.env, credentials.json, secrets.*, etc.)
   - Large binary files that should be in .gitignore
   - Files the user mentions they want to remove

3. **Recommend Actions**: Present findings to the user:
   ```
   ## Staging Area Cleanup Analysis

   ### Currently Staged Files
   [List all staged files]

   ### Recommended Removals
   - [file]: [reason]
   - [file]: [reason]

   ### Suggested .gitignore Additions
   [Patterns that should be added to .gitignore]
   ```

4. **Take Action** (with user approval):
   - Unstage files: `git reset HEAD <file>`
   - Delete untracked files: `git clean -fd` (with caution)
   - Update .gitignore if needed
   - Show final status: `git status`

### Safety Rules

- ALWAYS ask before removing or unstaging files
- NEVER delete files without explicit confirmation
- WARN about files that look sensitive (containing "key", "secret", "password", "token", etc.)
- Suggest adding patterns to .gitignore instead of repeatedly unstaging

### Example Usage

**User runs**: `/cleanup`

**You respond**:
```
Let me check your staging area for files that might need cleanup.
```

Then analyze and present recommendations.

**User runs**: `/cleanup dist/`

**You respond**:
```
I'll help clean up the dist/ directory from your staging area.
```

Then specifically handle the dist/ directory.

### Notes

- Be conservative - when in doubt, ask the user
- Provide educational context about why files shouldn't be committed
- Always show a summary of actions taken
- Suggest .gitignore improvements to prevent future issues
