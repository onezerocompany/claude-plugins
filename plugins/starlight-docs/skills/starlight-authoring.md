---
name: starlight-authoring
description: Use this skill when the user asks about "Starlight documentation", "Astro docs site", "Starlight components", "Rapide theme", "documentation authoring", "MDX components for docs", "Starlight Cards", "Starlight Tabs", "Starlight Asides", "FileTree component", "Steps component", "Badge component", "LinkCard", "CardGrid", "Starlight frontmatter", "Starlight sidebar", or needs guidance on creating documentation pages, using built-in components, configuring navigation, or styling documentation sites with Starlight and the Rapide theme.
---

# Starlight Documentation Authoring Expert

You are an expert in creating documentation websites using Astro Starlight with the Rapide theme. This skill provides comprehensive knowledge of components, frontmatter options, content authoring patterns, and best practices.

## Starlight Overview

Starlight is Astro's official documentation framework that provides:
- Built-in search powered by Pagefind
- Automatic navigation from file structure
- Dark/light theme support
- i18n support
- Component library for documentation patterns

## Rapide Theme

The Rapide theme (`starlight-theme-rapide`) provides a Visual Studio Code Vitesse-inspired design with enhanced component styling.

### Installation

```bash
pnpm add starlight-theme-rapide
```

### Configuration

```js
// astro.config.mjs
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightThemeRapide from 'starlight-theme-rapide';

export default defineConfig({
  integrations: [
    starlight({
      title: 'My Docs',
      plugins: [starlightThemeRapide()],
      sidebar: [
        // sidebar configuration
      ],
    }),
  ],
});
```

## Frontmatter Reference

Every documentation page requires frontmatter with at minimum a `title`:

```yaml
---
title: Page Title
description: Optional SEO description
slug: custom-url-slug
template: doc | splash
tableOfContents: true | false | { minHeadingLevel: 2, maxHeadingLevel: 3 }
draft: true | false
pagefind: true | false
editUrl: https://github.com/... | false
lastUpdated: 2024-01-15
prev: false | Previous Page | { link: '/path', label: 'Custom Label' }
next: false | Next Page | { link: '/path', label: 'Custom Label' }
sidebar:
  label: Custom Sidebar Label
  order: 1
  badge: New | { text: 'Deprecated', variant: 'caution' }
  hidden: false
---
```

### Hero Configuration

For landing pages using `template: splash`:

```yaml
---
title: Welcome
template: splash
hero:
  title: My Documentation
  tagline: The best docs ever
  image:
    file: ../../assets/hero.png
    alt: Hero image description
  actions:
    - text: Get Started
      link: /guides/getting-started/
      icon: right-arrow
      variant: primary
    - text: View on GitHub
      link: https://github.com/...
      icon: external
      variant: secondary
---
```

### Banner Configuration

```yaml
---
title: Page with Banner
banner:
  content: |
    This is a <a href="/announcements">special announcement</a>!
---
```

## Sidebar Configuration

Configure in `astro.config.mjs`:

```js
starlight({
  sidebar: [
    // Simple link (auto-pulls title from page)
    { slug: 'guides/getting-started' },

    // External link
    { label: 'GitHub', link: 'https://github.com/...' },

    // Group with manual items
    {
      label: 'Guides',
      items: [
        { slug: 'guides/installation' },
        { slug: 'guides/configuration' },
      ],
    },

    // Auto-generated group from directory
    {
      label: 'Reference',
      autogenerate: { directory: 'reference' },
    },

    // Collapsed group
    {
      label: 'Advanced',
      collapsed: true,
      items: [
        { slug: 'advanced/custom-css' },
      ],
    },

    // With badge
    {
      slug: 'new-feature',
      badge: { text: 'New', variant: 'success' },
    },

    // External link in new tab
    {
      label: 'External Docs',
      link: 'https://docs.example.com',
      attrs: { target: '_blank' },
    },
  ],
})
```

### Badge Variants

Available badge variants: `note`, `tip`, `caution`, `danger`, `success`

## Built-in Components

Import components from `@astrojs/starlight/components`:

```mdx
import { Card, CardGrid, LinkCard, Tabs, TabItem, Badge, Icon, Steps, Aside, FileTree, Code } from '@astrojs/starlight/components';
```

### Asides (Callouts)

Use markdown syntax or component:

```mdx
:::note
This is a note aside.
:::

:::tip
Helpful tip for users.
:::

:::caution
Be careful with this.
:::

:::danger
Critical warning!
:::

:::note[Custom Title]
Note with a custom title.
:::

{/* Or as component */}
<Aside type="tip" title="Pro Tip">
  Component-based aside content.
</Aside>
```

### Cards

```mdx
<Card title="Card Title" icon="star">
  Card content with markdown support.
</Card>

<CardGrid>
  <Card title="First Card" icon="rocket">
    First card content.
  </Card>
  <Card title="Second Card" icon="pencil">
    Second card content.
  </Card>
</CardGrid>

{/* Stagger effect for visual appeal */}
<CardGrid stagger>
  <Card title="Feature 1" icon="add-document">
    Description of feature 1.
  </Card>
  <Card title="Feature 2" icon="setting">
    Description of feature 2.
  </Card>
</CardGrid>
```

### Link Cards

```mdx
<LinkCard
  title="Getting Started"
  description="Learn how to set up your project"
  href="/guides/getting-started/"
/>

<CardGrid>
  <LinkCard title="Components" href="/reference/components/" />
  <LinkCard title="Configuration" href="/reference/config/" />
</CardGrid>
```

### Tabs

```mdx
<Tabs>
  <TabItem label="npm">
    ```bash
    npm install package-name
    ```
  </TabItem>
  <TabItem label="pnpm">
    ```bash
    pnpm add package-name
    ```
  </TabItem>
  <TabItem label="yarn">
    ```bash
    yarn add package-name
    ```
  </TabItem>
</Tabs>

{/* Synced tabs across the page using syncKey */}
<Tabs syncKey="package-manager">
  <TabItem label="npm">npm content</TabItem>
  <TabItem label="pnpm">pnpm content</TabItem>
</Tabs>

{/* Another synced group - will switch together */}
<Tabs syncKey="package-manager">
  <TabItem label="npm">More npm content</TabItem>
  <TabItem label="pnpm">More pnpm content</TabItem>
</Tabs>
```

### Steps

```mdx
<Steps>
1. **Install the package**

   Run the installation command for your package manager.

   ```bash
   pnpm add my-package
   ```

2. **Configure the integration**

   Add the integration to your config file.

3. **Start using it**

   Import and use the features in your project.
</Steps>
```

### Badge

```mdx
<Badge text="New" variant="success" />
<Badge text="Deprecated" variant="caution" />
<Badge text="Experimental" variant="note" />
<Badge text="Breaking" variant="danger" />
<Badge text="Default" />

{/* With size */}
<Badge text="Small" size="small" />
<Badge text="Medium" size="medium" />
<Badge text="Large" size="large" />
```

### Icon

```mdx
<Icon name="star" />
<Icon name="rocket" size="1.5rem" />
<Icon name="warning" color="var(--sl-color-orange)" />
```

Common icon names: `star`, `rocket`, `pencil`, `document`, `setting`, `add-document`, `open-book`, `information`, `warning`, `error`, `external`, `right-arrow`, `down-arrow`, `github`, `twitter`, `discord`

### FileTree

```mdx
<FileTree>
- src/
  - components/
    - Header.astro
    - Footer.astro
  - content/
    - docs/
      - index.mdx
      - getting-started.mdx
  - pages/
    - index.astro
- astro.config.mjs
- package.json
</FileTree>

{/* With highlights and comments */}
<FileTree>
- src/
  - **components/** Important folder
  - content/
    - docs/
      - index.mdx Entry point
      - _**getting-started.mdx**_ Highlighted file
</FileTree>
```

### Code Blocks

Use fenced code blocks with language identifiers:

````mdx
```js title="example.js"
const greeting = 'Hello, World!';
console.log(greeting);
```

```js title="example.js" {2-3}
const greeting = 'Hello';
// These lines are highlighted
const name = 'World';
console.log(`${greeting}, ${name}!`);
```

```js ins={2} del={3}
const items = [];
items.push('new item'); // Added
items.pop(); // Removed
```

```bash frame="terminal" title="Terminal"
pnpm dev
```

```js "important" /regex/
// Words matching "important" are highlighted
// Regex patterns like /regex/ are also highlighted
const important = 'value';
```
````

### Details (Expandable Content)

Use HTML details element:

```mdx
<details>
<summary>Click to expand</summary>

Hidden content that can include:
- Lists
- Code blocks
- Any markdown

```js
const example = 'code';
```

</details>
```

## Content Authoring Best Practices

### File Organization

```
src/content/docs/
├── index.mdx           # Landing page
├── guides/
│   ├── getting-started.mdx
│   ├── installation.mdx
│   └── configuration.mdx
├── reference/
│   ├── api.mdx
│   ├── components.mdx
│   └── config.mdx
└── examples/
    └── basic-usage.mdx
```

### Heading Structure

- Page title is automatically rendered as `<h1>`
- Start content with `<h2>` headings
- `<h2>` and `<h3>` appear in the table of contents
- Use semantic heading levels (don't skip levels)

### Images

```mdx
{/* Relative path (optimized by Astro) */}
![Alt text](../../assets/image.png)

{/* Import for more control */}
import myImage from '../../assets/image.png';
<Image src={myImage} alt="Description" />

{/* External URL */}
![Alt text](https://example.com/image.png)
```

### Internal Links

```mdx
{/* Link to other docs pages */}
[Getting Started](/guides/getting-started/)
[API Reference](/reference/api/#methods)

{/* Relative links */}
[Next page](./next-page/)
[Parent section](../overview/)
```

### Blockquotes

```mdx
> This is a blockquote.
> It can span multiple lines.

> **Note:** You can use formatting inside blockquotes.
```

### Tables

```mdx
| Feature | Supported |
|---------|-----------|
| MDX     | Yes       |
| Markdoc | Yes       |

{/* With alignment */}
| Left | Center | Right |
|:-----|:------:|------:|
| L    |   C    |     R |
```

## Advanced Configuration

### Custom CSS

Create `src/styles/custom.css` and import in `astro.config.mjs`:

```js
starlight({
  customCss: ['./src/styles/custom.css'],
})
```

### Extending the Schema

Add custom frontmatter fields:

```js
// src/content/config.ts
import { defineCollection } from 'astro:content';
import { docsSchema } from '@astrojs/starlight/schema';

export const collections = {
  docs: defineCollection({
    schema: docsSchema({
      extend: (context) => {
        return context.schema.extend({
          customField: z.string().optional(),
          category: z.enum(['guide', 'reference', 'tutorial']).optional(),
        });
      },
    }),
  }),
};
```

### Component Overrides

Override built-in components in `astro.config.mjs`:

```js
starlight({
  components: {
    Header: './src/components/CustomHeader.astro',
    Footer: './src/components/CustomFooter.astro',
    Hero: './src/components/CustomHero.astro',
  },
})
```

### Search Configuration

Starlight uses Pagefind for search. Exclude pages with:

```yaml
---
pagefind: false
---
```

### Internationalization

```js
starlight({
  defaultLocale: 'en',
  locales: {
    en: { label: 'English' },
    es: { label: 'Español', lang: 'es' },
    fr: { label: 'Français', lang: 'fr' },
  },
})
```

## Rapide Theme Specific Features

The Rapide theme enhances the default Starlight styling with:

- VS Code Vitesse-inspired color palette
- Enhanced code block styling
- Refined typography
- Improved component aesthetics

### Theme Colors

The theme provides both light and dark modes with carefully crafted color schemes that work well for technical documentation.

### Component Styling

All built-in Starlight components receive enhanced styling:
- Cards have refined shadows and borders
- Tabs have smooth transitions
- Asides have distinctive styling per type
- Code blocks have improved syntax highlighting
- File trees have better visual hierarchy

## Common Patterns

### Installation Instructions

```mdx
<Tabs syncKey="pkg">
  <TabItem label="npm">
    ```bash frame="terminal"
    npm install my-package
    ```
  </TabItem>
  <TabItem label="pnpm">
    ```bash frame="terminal"
    pnpm add my-package
    ```
  </TabItem>
  <TabItem label="yarn">
    ```bash frame="terminal"
    yarn add my-package
    ```
  </TabItem>
</Tabs>
```

### Feature Overview

```mdx
<CardGrid stagger>
  <Card title="Fast" icon="rocket">
    Built on Astro for optimal performance.
  </Card>
  <Card title="Flexible" icon="setting">
    Customize everything to your needs.
  </Card>
  <Card title="Accessible" icon="information">
    WCAG compliant out of the box.
  </Card>
</CardGrid>
```

### Quick Start Guide

```mdx
<Steps>
1. Install the package
   <Tabs syncKey="pkg">
     <TabItem label="npm">
       ```bash
       npm install my-package
       ```
     </TabItem>
     <TabItem label="pnpm">
       ```bash
       pnpm add my-package
       ```
     </TabItem>
   </Tabs>

2. Add to your config
   ```js title="astro.config.mjs"
   import myPackage from 'my-package';

   export default defineConfig({
     integrations: [myPackage()],
   });
   ```

3. Start using it
   You're ready to go!
</Steps>
```

### API Reference Table

```mdx
## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `title` | `string` | — | Required. The component title. |
| `icon` | `string` | `undefined` | Optional icon name. |
| `variant` | `'primary' \| 'secondary'` | `'primary'` | Visual variant. |

## Examples

<Tabs>
  <TabItem label="Basic">
    ```jsx
    <Component title="Hello" />
    ```
  </TabItem>
  <TabItem label="With Icon">
    ```jsx
    <Component title="Hello" icon="star" />
    ```
  </TabItem>
</Tabs>
```
