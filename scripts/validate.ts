#!/usr/bin/env bun

import { readFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = join(__dirname, '..');
const MARKETPLACE_PATH = join(ROOT_DIR, '.claude-plugin', 'marketplace.json');

let hasErrors = false;

interface Owner {
  name: string;
  email: string;
}

interface PluginSource {
  source: string;
  repo?: string;
  url?: string;
}

interface Plugin {
  name: string;
  description?: string;
  version?: string;
  source: string | PluginSource;
  keywords?: string[];
  author?: Owner;
}

interface Marketplace {
  name: string;
  description?: string;
  version?: string;
  owner: Owner;
  pluginRoot?: string;
  plugins: Plugin[];
}

function error(message: string): void {
  console.error(`❌ ERROR: ${message}`);
  hasErrors = true;
}

function warn(message: string): void {
  console.warn(`⚠️  WARNING: ${message}`);
}

function success(message: string): void {
  console.log(`✅ ${message}`);
}

function info(message: string): void {
  console.log(`ℹ️  ${message}`);
}

// Validate JSON syntax
function validateJSON(filePath: string, label: string): Marketplace | null {
  try {
    const content = readFileSync(filePath, 'utf-8');
    return JSON.parse(content) as Marketplace;
  } catch (err) {
    error(`${label} is not valid JSON: ${(err as Error).message}`);
    return null;
  }
}

// Validate marketplace.json structure
function validateMarketplace(marketplace: Marketplace): void {
  info('Validating marketplace.json structure...');

  // Required fields
  if (!marketplace.name) {
    error('marketplace.json missing required field: name');
  } else if (!/^[a-z0-9-]+$/.test(marketplace.name)) {
    error(`marketplace.json name must be kebab-case: ${marketplace.name}`);
  } else {
    success(`Marketplace name: ${marketplace.name}`);
  }

  if (!marketplace.owner) {
    error('marketplace.json missing required field: owner');
  } else {
    if (!marketplace.owner.name) {
      error('marketplace.json owner missing required field: name');
    }
    if (!marketplace.owner.email) {
      error('marketplace.json owner missing required field: email');
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(marketplace.owner.email)) {
      warn(`marketplace.json owner.email may not be valid: ${marketplace.owner.email}`);
    }
    if (!hasErrors) {
      success(`Owner: ${marketplace.owner.name} <${marketplace.owner.email}>`);
    }
  }

  if (!marketplace.plugins || !Array.isArray(marketplace.plugins)) {
    error('marketplace.json missing required field: plugins (must be an array)');
  } else {
    success(`Found ${marketplace.plugins.length} plugin(s)`);
  }

  // Optional but recommended
  if (!marketplace.description) {
    warn('marketplace.json missing recommended field: description');
  }

  if (!marketplace.version) {
    warn('marketplace.json missing recommended field: version');
  }
}

// Validate individual plugin entries
function validatePluginEntries(marketplace: Marketplace): void {
  if (!marketplace.plugins || !Array.isArray(marketplace.plugins)) {
    return;
  }

  info('\nValidating plugin entries...');

  const pluginNames = new Set<string>();

  for (const [index, plugin] of marketplace.plugins.entries()) {
    const pluginLabel = `Plugin #${index + 1}`;

    // Required fields
    if (!plugin.name) {
      error(`${pluginLabel} missing required field: name`);
      continue;
    } else if (!/^[a-z0-9-]+$/.test(plugin.name)) {
      error(`${pluginLabel} name must be kebab-case: ${plugin.name}`);
    }

    // Check for duplicate names
    if (pluginNames.has(plugin.name)) {
      error(`Duplicate plugin name: ${plugin.name}`);
    }
    pluginNames.add(plugin.name);

    if (!plugin.source) {
      error(`${pluginLabel} (${plugin.name}) missing required field: source`);
      continue;
    }

    // Validate source
    if (typeof plugin.source === 'string') {
      // Relative path source
      const pluginPath = join(ROOT_DIR, marketplace.pluginRoot || 'plugins', plugin.source);
      if (!existsSync(pluginPath)) {
        error(`${pluginLabel} (${plugin.name}) source path does not exist: ${plugin.source}`);
      } else {
        const manifestPath = join(pluginPath, '.claude-plugin', 'plugin.json');
        if (!existsSync(manifestPath)) {
          error(`${pluginLabel} (${plugin.name}) missing .claude-plugin/plugin.json at: ${manifestPath}`);
        } else {
          success(`Plugin: ${plugin.name} (${plugin.source})`);
        }
      }
    } else if (typeof plugin.source === 'object') {
      // External source (github, url, etc.)
      if (!plugin.source.source) {
        error(`${pluginLabel} (${plugin.name}) source object missing 'source' field`);
      } else if (plugin.source.source === 'github') {
        if (!plugin.source.repo) {
          error(`${pluginLabel} (${plugin.name}) github source missing 'repo' field`);
        } else {
          success(`Plugin: ${plugin.name} (github:${plugin.source.repo})`);
        }
      } else if (plugin.source.source === 'url') {
        if (!plugin.source.url) {
          error(`${pluginLabel} (${plugin.name}) url source missing 'url' field`);
        } else {
          success(`Plugin: ${plugin.name} (${plugin.source.url})`);
        }
      } else {
        warn(`${pluginLabel} (${plugin.name}) unknown source type: ${plugin.source.source}`);
      }
    } else {
      error(`${pluginLabel} (${plugin.name}) source must be string or object`);
    }

    // Recommended fields
    if (!plugin.description) {
      warn(`${pluginLabel} (${plugin.name}) missing recommended field: description`);
    }

    if (!plugin.version) {
      warn(`${pluginLabel} (${plugin.name}) missing recommended field: version`);
    }
  }
}

// Main validation
function main(): void {
  console.log('🔍 Validating Claude Plugins Marketplace\n');

  // Check marketplace.json exists
  if (!existsSync(MARKETPLACE_PATH)) {
    error(`marketplace.json not found at: ${MARKETPLACE_PATH}`);
    process.exit(1);
  }

  // Parse and validate marketplace.json
  const marketplace = validateJSON(MARKETPLACE_PATH, 'marketplace.json');
  if (!marketplace) {
    process.exit(1);
  }

  validateMarketplace(marketplace);
  validatePluginEntries(marketplace);

  // Summary
  console.log('\n' + '='.repeat(50));
  if (hasErrors) {
    console.log('❌ Validation failed with errors');
    process.exit(1);
  } else {
    console.log('✅ Validation passed successfully');
    process.exit(0);
  }
}

main();
