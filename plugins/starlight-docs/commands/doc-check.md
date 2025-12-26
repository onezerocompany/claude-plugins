---
name: doc-check
description: Validate documentation structure, check for broken internal links, validate frontmatter, and identify common documentation issues
---

# Documentation Check Command

Validate documentation structure, check for broken internal links, validate frontmatter, and identify common documentation issues in Starlight documentation sites.

## Instructions

You are helping the user validate their Starlight documentation site. This command performs comprehensive checks across multiple categories to ensure documentation quality and consistency.

**⚡ Tool-First Approach**: This command is designed to maximize tool usage and minimize AI inference. Use Glob, Grep, and Read tools to gather all data, then let AI analyze only the collected results. Never manually parse files when tools can do it.

### Process

**IMPORTANT**: This command should maximize tool usage and minimize AI processing. Use tools to gather data, then let AI analyze only the findings.

1. **Determine Scope**: Check what the user wants to validate:
   - Entire docs directory (default: `src/content/docs/`)
   - Specific directory or file path
   - Note any flags like `--fix` for auto-fixing issues

2. **Use Tools to Gather Context** (parallel execution where possible):
   - **Glob**: `**/*.{md,mdx}` to find all doc files in scope
   - **Glob**: `**/astro.config.{js,mjs,ts}` to find config
   - **Read**: Read config file to understand sidebar structure
   - This gives you: list of all files, sidebar configuration

3. **Use Tools for Pattern Discovery** (run searches in parallel):
   - **Grep** with `output_mode: "content"` to find:
     - Markdown links: `\[([^\]]+)\]\(([^)]+)\)`
     - Image tags: `!\[([^\]]*)\]\(([^)]+)\)` and `<img[^>]*>`
     - LinkCard components: `<LinkCard[^>]+href=["']([^"']+)["']`
     - Headings: `^#{1,6}\s+(.+)$`
     - TODO comments: `TODO|FIXME|XXX|HACK`
     - Import statements: `^import\s+\{([^}]+)\}\s+from`
   - **Grep** to validate patterns:
     - Empty alt text: `!\[\]\(` or `alt=""`
     - Non-descriptive links: `\[(click here|here|read more|link|this)\]\(`
   - This eliminates need for AI to parse files manually

4. **Use Read Tool Strategically**:
   - Only read specific files when validating:
     - Frontmatter (files flagged by Grep for missing fields)
     - Anchor links (target files to verify heading exists)
     - Link destinations (to verify files exist)
   - Extract frontmatter between `---` markers
   - Parse only what's needed for validation

5. **Let AI Analyze Tool Results**:
   - Cross-reference Grep results with Glob file list
   - Validate links point to existing files from Glob results
   - Check frontmatter against requirements
   - Identify orphaned pages (files not in sidebar)
   - Detect duplicate slugs
   - Flag quality issues from pattern matches

6. **Report Results**: Present findings in structured format with severity levels (ERROR, WARN, INFO)

7. **Auto-Fix (if --fix flag)**: Use Edit tool to apply fixes for issues identified by tools

## Validation Categories

### 1. Link Validation

Check all internal links and anchors in documentation files:

- **Internal Links**: Verify all `[text](/path/)` links resolve to existing pages
- **Relative Links**: Check `./` and `../` relative links work correctly
- **Anchor Links**: Validate `#heading-id` anchors exist in target pages
- **Component Links**: Check LinkCard and other component href attributes

**How to Check with Tools**:
1. **Grep** for all markdown links with `output_mode: "content"`:
   - Pattern: `\[([^\]]+)\]\(([^)]+)\)`
   - Pattern: `<LinkCard[^>]+href=["']([^"']+)["']`
   - Result: File paths + line numbers + matched links
2. **Grep** for all headings to build heading index:
   - Pattern: `^#{1,6}\s+(.+)$`
   - Use multiline mode if needed
   - Result: All headings per file with line numbers
3. **Glob** for all `.md` and `.mdx` files to get complete file list
4. **AI Analysis** of tool results:
   - Cross-reference links from Grep with files from Glob
   - For each link:
     - If starts with `/`: verify file exists in Glob results
     - If starts with `./` or `../`: resolve relative path, verify in Glob results
     - If starts with `#`: check heading exists in Grep heading results for same file
     - If contains `#`: verify file exists AND heading exists in Grep results
     - External links (http/https): flag for manual verification
   - Report only broken links with file:line reference

**Example Checks**:
```javascript
// Link: [Getting Started](/guides/getting-started/)
// Check: does src/content/docs/guides/getting-started.md or .mdx exist?

// Link: [API](#methods)
// Check: does current file have heading "## methods" or "## Methods"?

// Link: [Config](../reference/config/#options)
// Check: does ../reference/config.md exist AND have heading "## options"?
```

### 2. Frontmatter Validation

Validate frontmatter in all documentation files:

- **Required Fields**: Ensure `title` field exists in every file
- **Recommended Fields**: Check for `description` (important for SEO)
- **Field Types**: Validate field values are correct type
- **Deprecated Options**: Flag use of deprecated frontmatter fields
- **Hero Configuration**: For `template: splash` pages, validate hero structure
- **Sidebar Config**: Check `sidebar.order`, `sidebar.label`, `sidebar.badge` format

**How to Check with Tools**:
1. **Grep** to find files with potential frontmatter issues:
   - Pattern: `^---$` with multiline to identify frontmatter blocks
   - Pattern: `^title:\s*$` to find empty titles (ERROR)
   - Pattern: `^---\n[\s\S]*?\n---` without `description:` to find missing descriptions (WARN)
2. **Read** only files flagged by Grep or all files if doing comprehensive check:
   - Extract frontmatter between `---` markers
   - Parse as YAML/JSON
3. **AI Validation** of frontmatter:
   - `title`: must be present and non-empty string
   - `description`: should exist (WARN if missing)
   - `template`: if 'splash', check `hero` configuration
   - `sidebar.order`: if present, should be number
   - `sidebar.badge`: if present, check variant is valid
   - `tableOfContents`: if object, check minHeadingLevel < maxHeadingLevel
   - Report issues with file reference

**Example Validation**:
```yaml
---
title: "" # ERROR: title is empty
description: # WARN: description missing
sidebar:
  order: "1" # WARN: order should be number, not string
  badge:
    variant: "invalid" # ERROR: invalid variant (should be note/tip/caution/danger/success)
---
```

### 3. Structure Validation

Check documentation structure and organization:

- **Orphaned Pages**: Find files not referenced in sidebar configuration
- **Duplicate Slugs**: Detect files that would generate the same URL
- **Heading Hierarchy**: Ensure headings follow proper nesting (no skipping levels)
- **Table of Contents**: Validate ToC configuration

**How to Check with Tools**:

**Orphaned Pages**:
1. **Read** `astro.config.mjs` to get sidebar configuration
2. **Glob** `src/content/docs/**/*.{md,mdx}` to get all doc files
3. **AI Analysis**: Extract slugs from sidebar config, compare with Glob results
4. Report files not referenced in sidebar (WARN)

**Duplicate Slugs**:
1. **Glob** to get all doc files
2. **Grep** for custom slug frontmatter: `^slug:\s*(.+)$`
3. **AI Analysis**: Generate URL slug for each file, check for duplicates
4. Flag duplicates (ERROR)

**Heading Hierarchy**:
1. **Grep** all headings with `output_mode: "content"`:
   - Pattern: `^#{1,6}\s+(.+)$`
   - Results include file, line number, heading level
2. **AI Analysis**:
   - Track heading levels per file
   - Ensure no skipping (e.g., ## → #### without ###)
   - Page title is h1, content should start with h2
   - Report hierarchy violations with file:line

**Example**:
```markdown
# Don't include h1 in content (page title is h1)

## Good h2

#### Bad h4 (ERROR: skipped h3)

### Now h3 is ok
```

### 4. Content Quality

Check for content quality issues:

- **Missing Image Alt Text**: Find images without alt attributes
- **Unused Imports**: Detect component imports that aren't used
- **Empty Code Blocks**: Find code blocks with no content
- **TODO/FIXME Comments**: Flag unfinished documentation
- **Very Short Pages**: Identify pages under ~200 words that might need expansion
- **Broken Code Blocks**: Check for unclosed code fences

**How to Check with Tools**:

**Missing Alt Text**:
1. **Grep** for images with empty alt:
   - Pattern: `!\[\]\(` (markdown image with no alt)
   - Pattern: `<img[^>]*>` then check for `alt=""` or missing alt
2. Report findings with file:line (WARN)

**Unused Imports**:
1. **Grep** for all imports with `output_mode: "content"`:
   - Pattern: `^import\s+\{([^}]+)\}\s+from`
2. **Grep** for usage of each imported component in same file
3. **AI Analysis**: Compare imports vs usage, flag unused (INFO)

**Empty Code Blocks**:
1. **Grep** for code blocks with `multiline: true`:
   - Pattern: ` ```[a-z]*\n\s*\n``` ` (code fence with only whitespace)
2. Report findings with file:line (WARN)

**TODO/FIXME**:
1. **Grep** with `-i` (case insensitive):
   - Pattern: `TODO|FIXME|XXX|HACK`
   - Output mode: "content" for file:line details
2. Report all matches (INFO)

**Short Pages**:
1. **Grep** or **Read** to get content length
2. **AI Analysis**: Count words excluding frontmatter and code blocks
3. If < 200 words: flag as INFO

### 5. Accessibility

Check for accessibility issues:

- **Heading Skip Levels**: Covered in Structure Validation
- **Image Alt Quality**: Check if alt text is meaningful
- **Link Text**: Flag non-descriptive link text like "click here", "here", "read more"
- **Empty Links**: Find links with no text content

**How to Check with Tools**:

**Alt Text Quality**:
1. **Grep** for poor alt text patterns with `-i`:
   - Pattern: `!\[(image|img|picture|photo|screenshot)\]\(`
   - Pattern: `!\[[^\]]*\.(png|jpg|jpeg|gif|svg)\]\(` (filename as alt)
2. Report findings with suggestions (INFO)

**Link Text Meaningfulness**:
1. **Grep** with `-i` for non-descriptive link text:
   - Pattern: `\[(click here|here|read more|link|this)\]\(`
2. Report all matches with file:line (WARN)

**Empty Links**:
1. **Grep** for empty links:
   - Pattern: `\[\]\([^)]+\)` (markdown empty link)
   - Pattern: `<a[^>]+href=[^>]*></a>` (HTML empty link)
2. Report all matches with file:line (ERROR)

## Output Format

Present findings in a clear, structured format:

```markdown
## Documentation Check: {path}

### Links (X issues)
- ERROR: guides/installation.mdx:45 - Link to '/api/config' not found
- WARN: reference/api.mdx:12 - Anchor '#deprecated-options' not found in target

### Frontmatter (X issues)
- ERROR: guides/basics.mdx - Missing required 'title' field
- WARN: guides/advanced.mdx - Missing recommended 'description' field
- INFO: index.mdx - Hero image alt text could be more descriptive

### Structure (X issues)
- WARN: Orphaned page: examples/legacy.mdx (not in sidebar)
- ERROR: Duplicate slug 'getting-started': guides/getting-started.mdx, intro/getting-started.mdx
- WARN: guides/tutorial.mdx:34 - Heading level skip (h2 -> h4)

### Content Quality (X issues)
- WARN: components/card.mdx:12 - Image missing alt text
- INFO: reference/api.mdx:89 - TODO comment: 'Add more examples'
- INFO: guides/basics.mdx - Very short page (143 words, consider expanding)
- INFO: utils/helpers.mdx:5 - Unused import: Badge

### Accessibility (X issues)
- WARN: installation.mdx:23 - Non-descriptive link text: "click here"
- INFO: hero.png alt text is filename-based, consider more descriptive text

---
**Summary**: 3 errors, 6 warnings, 5 info

Run with --fix to auto-fix simple issues.
```

## Auto-Fix Capabilities

When user runs with `--fix` flag, automatically fix these issues:

1. **Broken Internal Links** (if detectable):
   - If file was moved/renamed and can be inferred, update link
   - Only fix if confident about the correction

2. **Missing Descriptions**:
   - Generate from first paragraph of content
   - Take first 1-2 sentences, max 160 characters

3. **Unused Imports**:
   - Remove import statements for unused components
   - Preserve imports that are used

4. **Simple Typos**:
   - Fix common frontmatter typos (e.g., `titel` -> `title`)

**Process for --fix**:
- Show what will be fixed before applying
- Apply fixes using Edit tool
- Report what was fixed
- Note any issues that couldn't be auto-fixed

## Example Usage

```
User: /doc-check

Response: I'll check your entire documentation site for issues.
[Runs all validation checks on src/content/docs/]
[Presents findings in structured format]
```

```
User: /doc-check src/content/docs/guides/

Response: I'll check the guides directory.
[Runs validation checks on guides directory only]
```

```
User: /doc-check --fix

Response: I'll check your docs and auto-fix simple issues.
[Runs checks, identifies fixable issues]
[Shows planned fixes]
[Applies fixes with user confirmation]
[Reports results]
```

## Implementation Notes

**Tool Usage Strategy** (maximize tool usage, minimize AI processing):

1. **Discovery Phase** (run in parallel):
   - **Glob**: Find all `.md` and `.mdx` files in scope
   - **Glob**: Find config files (`astro.config.*`)
   - **Read**: Config file for sidebar structure

2. **Pattern Extraction Phase** (run Grep searches in parallel):
   - All markdown links: `\[([^\]]+)\]\(([^)]+)\)`
   - All headings: `^#{1,6}\s+(.+)$`
   - All images: `!\[([^\]]*)\]\(([^)]+)\)`
   - LinkCard components: `<LinkCard[^>]+href=["']([^"']+)["']`
   - Import statements: `^import\s+\{([^}]+)\}\s+from`
   - TODO comments: `TODO|FIXME|XXX|HACK`
   - Empty alt text: `!\[\]\(`
   - Non-descriptive links: `\[(click here|here|read more|link|this)\]\(` with `-i`
   - Empty links: `\[\]\([^)]+\)`
   - Poor alt text: `!\[(image|img|picture)\]\(` with `-i`

3. **Targeted Reading Phase** (only when needed):
   - **Read**: Files to extract frontmatter (if not found by Grep)
   - **Read**: Target files to verify anchor links
   - Minimize file reads by using Grep results

4. **AI Analysis Phase**:
   - Cross-reference all tool results
   - Validate links against file list
   - Check frontmatter validity
   - Identify orphaned pages
   - Detect duplicates
   - Build comprehensive issue report

5. **Fix Phase** (if `--fix` flag):
   - **Edit**: Apply fixes for issues identified by tools
   - Report what was fixed

**Key Principles**:
- Let tools do the heavy lifting (pattern matching, file discovery)
- AI focuses on cross-referencing and validation logic
- Use parallel tool execution for efficiency
- Provide precise file:line references from Grep results
- Handle both `.md` and `.mdx` file extensions
- Consider `index.mdx` files for directory URLs

## Tips for Effective Checking

1. **Be thorough but not overwhelming**: Group related issues together
2. **Prioritize**: Show ERRORs first, then WARNs, then INFO
3. **Be specific**: Include file path and line number for each issue
4. **Be helpful**: Suggest fixes where possible
5. **Be accurate**: Only report actual issues, not false positives
6. **Context matters**: Consider the project's documentation style and conventions
