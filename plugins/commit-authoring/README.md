# Commit Authoring Plugin

Intelligent git commit management with AI-powered message generation, staging analysis, and cleanup utilities.

## Features

### Commands

#### `/commit [context]`
Analyzes your current changes and creates a well-crafted git commit with an AI-generated message.

**What it does:**
- Analyzes both staged and unstaged changes
- Reviews recent commit history to match your repository's style
- Generates conventional commit messages (feat:, fix:, docs:, etc.)
- Provides detailed analysis before committing
- Always asks for approval before creating the commit

**Usage:**
```bash
/commit
/commit fixing authentication bug
/commit adding new user profile feature
```

#### `/amend [context|--no-edit]`
Intelligently amends the last commit with new changes and optionally regenerates the commit message.

**What it does:**
- Checks if the last commit has been pushed (warns about force push implications)
- Analyzes both the original commit and new changes
- Determines if the commit message should be updated based on change significance
- Generates an updated message that incorporates both original and new changes
- Shows before/after comparison of commit messages
- Handles the "oops, forgot to stage that file" scenario
- Always requires user confirmation before amending

**Usage:**
```bash
/amend                      # Amend with staged changes, optionally update message
/amend --no-edit            # Keep original message (for adding forgotten files)
/amend fixing the typo      # Amend with context about what was added
```

**Safety features:**
- Warns if commit has been pushed to remote
- Shows clear diff of what will be amended
- Suggests splitting into new commit if changes are too different
- Never amends without explicit approval

#### `/cleanup [path]`
Cleans up your git staging area by identifying and removing files that shouldn't be committed.

**What it does:**
- Scans staged files for common issues (build artifacts, IDE files, OS files, etc.)
- Identifies sensitive files (API keys, credentials, secrets)
- Recommends files to unstage
- Suggests .gitignore patterns to prevent future issues
- Safely removes or unstages files with your approval

**Usage:**
```bash
/cleanup                    # Analyze entire staging area
/cleanup dist/              # Clean up specific directory
/cleanup node_modules/      # Remove specific path
```

### Agents

#### `commit-author`
A specialized agent that handles the entire commit creation process with intelligence and care.

**Capabilities:**
- Deep analysis of code changes
- Context-aware commit message generation
- Conventional commit format support
- Multi-file change analysis
- Sensitive data detection
- Commit style consistency

**How it works:**
1. Runs `git status`, `git diff`, and `git log` to gather context
2. Analyzes the nature and scope of changes
3. Generates appropriate commit message following conventions
4. Presents analysis and proposed message
5. Waits for your approval before committing

#### `amend-author`
A specialized agent that safely handles commit amendments with intelligent message updates.

**Capabilities:**
- Safety checks for pushed commits
- Analysis of original commit and new changes
- Smart decision-making on whether to update commit message
- Before/after message comparison
- Force push warnings
- Change significance assessment

**How it works:**
1. Checks if the commit has been pushed (warns about force push)
2. Analyzes the original commit message and changes
3. Reviews new staged/unstaged changes
4. Determines if message should be updated based on change significance
5. Generates updated message incorporating both old and new changes
6. Shows before/after comparison
7. Waits for approval before amending

## Installation

This plugin is part of the claude-plugins marketplace. To install:

1. Clone the marketplace repository
2. Claude Code will automatically detect the plugin
3. Commands and agents will be available immediately

## Best Practices

### When to use `/commit`
- After making logical, cohesive changes
- When you want AI assistance crafting the perfect message
- To maintain consistent commit style across your team
- When unsure how to describe complex changes

### When to use `/amend`
- When you forgot to stage files in your last commit
- After making small fixes or additions to recent work
- When you want to update the commit message to reflect additional changes
- Before pushing - never amend commits that have been pushed without good reason
- When the new changes logically belong with the previous commit

**When NOT to use `/amend`:**
- After the commit has been pushed (unless you understand force push implications)
- When the new changes represent different functionality (make a new commit instead)
- On commits that other developers may have based work on

### When to use `/cleanup`
- Before committing, to ensure you're not including unwanted files
- After bulk file operations that may have staged artifacts
- When you see files in `git status` that shouldn't be there
- To get recommendations for .gitignore improvements

### Commit Message Conventions

The plugin follows Conventional Commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Common types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes
- `build`: Build system changes

## Examples

### Example 1: Creating a Feature Commit

```bash
# You: /commit
# Agent analyzes changes...

## Commit Analysis

**Files Changed**:
- src/components/UserProfile.tsx
- src/api/users.ts
- src/types/user.ts

**Change Type**: feat
**Scope**: user-profile

## Proposed Commit Message

feat(user-profile): add profile picture upload functionality

Implement image upload component with preview, validation, and
AWS S3 integration. Includes file size limits and format restrictions.

- Add ProfilePictureUpload component
- Integrate S3 presigned URL generation
- Add user avatar display in profile view
- Update user type definitions


## Changes Summary
Added complete profile picture upload feature with client-side validation,
S3 integration, and preview functionality.

Proceed with this commit?

# You: yes
# Agent commits with the message
```

### Example 2: Cleaning Up Staging Area

```bash
# You: /cleanup

## Staging Area Cleanup Analysis

### Currently Staged Files
- src/app.ts
- dist/bundle.js
- dist/bundle.js.map
- .DS_Store
- node_modules/.cache/webpack
- .env.local

### Recommended Removals
- dist/bundle.js: Build artifact (should not be committed)
- dist/bundle.js.map: Build artifact (should not be committed)
- .DS_Store: OS file (should not be committed)
- node_modules/.cache/webpack: Dependency cache (should not be committed)
- .env.local: SENSITIVE - Environment file with secrets!

### Suggested .gitignore Additions
dist/
.DS_Store
.env.local
node_modules/

Shall I unstage these files and update your .gitignore?
```

## Tips

1. **Review before committing**: Always review the proposed commit message and make adjustments if needed
2. **Use descriptive context**: When running `/commit [context]`, provide helpful context about your changes
3. **Regular cleanup**: Run `/cleanup` periodically to catch accidentally staged files
4. **Learn from suggestions**: The plugin's .gitignore recommendations help improve your repository hygiene
5. **Split commits**: If the agent suggests your changes are too broad, consider splitting them into multiple commits

## Security

The plugin includes safety measures:
- Never commits without explicit approval
- Detects sensitive files (API keys, credentials, secrets)
- Warns about files matching sensitive patterns
- Recommends .gitignore patterns for security

## Contributing

Found an issue or have a suggestion? Please open an issue at:
https://github.com/OneZeroCompany/claude-plugins

## License

MIT License - See LICENSE file for details
