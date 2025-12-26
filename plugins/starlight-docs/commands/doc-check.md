---
name: doc-check
description: Validate documentation structure, check for broken internal links, validate frontmatter, and identify common documentation issues
---

# Documentation Check Command

Validate documentation structure, check for broken internal links, validate frontmatter, and identify common documentation issues in Starlight documentation sites.

## Instructions

You are helping the user validate their Starlight documentation site. This command performs comprehensive checks across multiple categories to ensure documentation quality and consistency.

### Process

1. **Determine Scope**: Check what the user wants to validate:
   - Entire docs directory (default: `src/content/docs/`)
   - Specific directory or file path
   - Note any flags like `--fix` for auto-fixing issues

2. **Gather Context**: Before running checks, understand the project structure:
   - Read `astro.config.mjs` to understand sidebar configuration
   - Identify the docs directory location
   - List all documentation files to check

3. **Run Validation Categories**: Perform all applicable checks and collect findings

4. **Report Results**: Present findings in a structured format with severity levels (ERROR, WARN, INFO)

5. **Auto-Fix (if --fix flag)**: Apply automatic fixes for simple issues when requested

## Validation Categories

### 1. Link Validation

Check all internal links and anchors in documentation files:

- **Internal Links**: Verify all `[text](/path/)` links resolve to existing pages
- **Relative Links**: Check `./` and `../` relative links work correctly
- **Anchor Links**: Validate `#heading-id` anchors exist in target pages
- **Component Links**: Check LinkCard and other component href attributes

**How to Check**:
- Read each `.md` and `.mdx` file in the docs directory
- Extract all markdown links using regex: `\[([^\]]+)\]\(([^)]+)\)`
- Extract LinkCard hrefs: `<LinkCard[^>]+href=["']([^"']+)["']`
- For each link:
  - If starts with `/`: resolve from docs root
  - If starts with `./` or `../`: resolve relative to current file
  - If starts with `#`: check heading exists in current file
  - If contains `#`: check file exists and heading exists in that file
  - External links (http/https): flag for manual verification

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

**How to Check**:
- Extract frontmatter from each file (between `---` markers)
- Parse as YAML
- Validate:
  - `title`: must be present and non-empty string
  - `description`: should exist (WARN if missing)
  - `template`: if 'splash', check `hero` configuration
  - `sidebar.order`: if present, should be number
  - `sidebar.badge`: if present, check variant is valid
  - `tableOfContents`: if object, check minHeadingLevel < maxHeadingLevel

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

**How to Check**:

**Orphaned Pages**:
- Read sidebar configuration from `astro.config.mjs`
- Extract all `slug` references and `autogenerate` directories
- Compare with actual files in `src/content/docs/`
- Files not in sidebar = orphaned (WARN)

**Duplicate Slugs**:
- Generate URL slug for each file (filename without extension)
- Check for custom `slug` in frontmatter
- Flag any duplicates (ERROR)

**Heading Hierarchy**:
- Parse markdown headings from each file
- Track heading levels (## = h2, ### = h3, etc.)
- Ensure no skipping (e.g., ## followed by #### without ###)
- Page title is h1, so content should start with h2

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

**How to Check**:

**Missing Alt Text**:
- Find markdown images: `!\[([^\]]*)\]\(([^)]+)\)`
- If alt text (group 1) is empty: WARN
- Find HTML images: `<img[^>]*>`
- Check for `alt=""` or missing alt: WARN

**Unused Imports**:
- Extract imports: `import \{([^}]+)\} from`
- Check if each imported name appears elsewhere in file
- If not used: INFO (suggest removal)

**Empty Code Blocks**:
- Find code blocks: ` ```[\s\S]*?``` `
- Check if content between fences is only whitespace: WARN

**TODO/FIXME**:
- Search for `TODO`, `FIXME`, `XXX`, `HACK` in content
- Flag as INFO

**Short Pages**:
- Count words in content (excluding frontmatter, code blocks)
- If < 200 words: INFO (might need expansion)

### 5. Accessibility

Check for accessibility issues:

- **Heading Skip Levels**: Covered in Structure Validation
- **Image Alt Quality**: Check if alt text is meaningful
- **Link Text**: Flag non-descriptive link text like "click here", "here", "read more"
- **Empty Links**: Find links with no text content

**How to Check**:

**Alt Text Quality**:
- Check if alt text is just filename or generic like "image", "img", "picture"
- Suggest more descriptive alt text: INFO

**Link Text Meaningfulness**:
- Find links with text like: "click here", "here", "read more", "link", "this"
- Case insensitive check
- WARN: Links should have descriptive text

**Empty Links**:
- Find `[](url)` or `<a href="..."></a>`
- ERROR: Links must have text content

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

- Use Glob tool to find all `.md` and `.mdx` files
- Use Read tool to examine file contents
- Use Edit tool for auto-fixing when `--fix` is specified
- Parse frontmatter by extracting content between `---` markers
- Use regex for link and image extraction
- Track line numbers for precise error reporting
- Handle both `.md` and `.mdx` file extensions
- Consider `index.mdx` files for directory URLs

## Tips for Effective Checking

1. **Be thorough but not overwhelming**: Group related issues together
2. **Prioritize**: Show ERRORs first, then WARNs, then INFO
3. **Be specific**: Include file path and line number for each issue
4. **Be helpful**: Suggest fixes where possible
5. **Be accurate**: Only report actual issues, not false positives
6. **Context matters**: Consider the project's documentation style and conventions
