#!/usr/bin/env bun

import { readFileSync, existsSync, readdirSync, statSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = join(__dirname, '..');
const PLUGINS_DIR = join(ROOT_DIR, 'plugins');

let hasErrors = false;
let warnings = 0;

interface Owner {
  name: string;
  email: string;
}

interface Command {
  name: string;
  description?: string;
  prompt?: string;
  file?: string;
}

interface Agent {
  name: string;
  description?: string;
  prompt?: string;
}

interface PluginManifest {
  name: string;
  version: string;
  description: string;
  author?: Owner;
  license?: string;
  keywords?: string[];
  commands?: Command[] | string | string[];
  agents?: Agent[] | string | string[];
  skills?: string | string[];
  hooks?: unknown;
  mcpServers?: unknown;
}

function error(message: string): void {
  console.error(`❌ ERROR: ${message}`);
  hasErrors = true;
}

function warn(message: string): void {
  console.warn(`⚠️  WARNING: ${message}`);
  warnings++;
}

function success(message: string): void {
  console.log(`✅ ${message}`);
}

function info(message: string): void {
  console.log(`ℹ️  ${message}`);
}

// Validate JSON syntax
function validateJSON(filePath: string): PluginManifest | null {
  try {
    const content = readFileSync(filePath, 'utf-8');
    return JSON.parse(content) as PluginManifest;
  } catch (err) {
    error(`Invalid JSON in ${filePath}: ${(err as Error).message}`);
    return null;
  }
}

// Validate plugin manifest
function validatePluginManifest(pluginDir: string, pluginName: string): boolean {
  const manifestPath = join(pluginDir, '.claude-plugin', 'plugin.json');

  if (!existsSync(manifestPath)) {
    error(`Plugin ${pluginName} missing .claude-plugin/plugin.json`);
    return false;
  }

  const manifest = validateJSON(manifestPath);
  if (!manifest) {
    return false;
  }

  let pluginValid = true;

  // Required fields
  if (!manifest.name) {
    error(`${pluginName}/.claude-plugin/plugin.json missing required field: name`);
    pluginValid = false;
  } else if (manifest.name !== pluginName) {
    warn(`${pluginName}/.claude-plugin/plugin.json name "${manifest.name}" doesn't match directory name "${pluginName}"`);
  }

  if (!manifest.version) {
    error(`${pluginName}/.claude-plugin/plugin.json missing required field: version`);
    pluginValid = false;
  } else if (!/^\d+\.\d+\.\d+/.test(manifest.version)) {
    warn(`${pluginName}/.claude-plugin/plugin.json version should follow semver: ${manifest.version}`);
  }

  if (!manifest.description) {
    error(`${pluginName}/.claude-plugin/plugin.json missing required field: description`);
    pluginValid = false;
  }

  // Recommended fields
  if (!manifest.author) {
    warn(`${pluginName}/.claude-plugin/plugin.json missing recommended field: author`);
  }

  if (!manifest.license) {
    warn(`${pluginName}/.claude-plugin/plugin.json missing recommended field: license`);
  }

  if (!manifest.keywords || manifest.keywords.length === 0) {
    warn(`${pluginName}/.claude-plugin/plugin.json missing keywords for discoverability`);
  }

  // Check for at least one component
  const hasComponents = manifest.commands || manifest.agents || manifest.skills || manifest.hooks || manifest.mcpServers;
  if (!hasComponents) {
    warn(`${pluginName}/.claude-plugin/plugin.json should have at least one component (commands, agents, skills, hooks, or mcpServers)`);
  }

  // Validate commands if present
  if (manifest.commands) {
    if (typeof manifest.commands === 'string') {
      // Commands are defined in an external directory
      if (!manifest.commands.startsWith('./')) {
        error(`${pluginName}/.claude-plugin/plugin.json commands path must start with './'`);
        pluginValid = false;
      }
      const commandsPath = join(pluginDir, manifest.commands);
      if (!existsSync(commandsPath)) {
        error(`${pluginName}/.claude-plugin/plugin.json commands path does not exist: ${manifest.commands}`);
        pluginValid = false;
      }
    } else if (!Array.isArray(manifest.commands)) {
      error(`${pluginName}/.claude-plugin/plugin.json commands must be an array or string path`);
      pluginValid = false;
    } else {
      // Array can be file paths (strings) or command objects
      for (const [index, command] of manifest.commands.entries()) {
        if (typeof command === 'string') {
          // File path to markdown command file
          if (!command.startsWith('./')) {
            error(`${pluginName}/.claude-plugin/plugin.json command #${index + 1} path must start with './'`);
            pluginValid = false;
          } else {
            const commandPath = join(pluginDir, command);
            if (!existsSync(commandPath)) {
              error(`${pluginName}/.claude-plugin/plugin.json command file does not exist: ${command}`);
              pluginValid = false;
            } else {
              success(`Command file exists: ${command}`);
            }
          }
        } else {
          // Inline command object
          if (!command.name) {
            error(`${pluginName}/.claude-plugin/plugin.json command #${index + 1} missing name`);
            pluginValid = false;
          }
          if (!command.description) {
            warn(`${pluginName}/.claude-plugin/plugin.json command "${command.name}" missing description`);
          }
          if (!command.prompt && !command.file) {
            error(`${pluginName}/.claude-plugin/plugin.json command "${command.name}" must have either prompt or file`);
            pluginValid = false;
          }
        }
      }
    }
  }

  // Validate agents if present
  if (manifest.agents) {
    if (typeof manifest.agents === 'string') {
      // Agents are defined in an external directory
      if (!manifest.agents.startsWith('./')) {
        error(`${pluginName}/.claude-plugin/plugin.json agents path must start with './'`);
        pluginValid = false;
      }
      const agentsPath = join(pluginDir, manifest.agents);
      if (!existsSync(agentsPath)) {
        error(`${pluginName}/.claude-plugin/plugin.json agents path does not exist: ${manifest.agents}`);
        pluginValid = false;
      }
    } else if (!Array.isArray(manifest.agents)) {
      error(`${pluginName}/.claude-plugin/plugin.json agents must be an array or string path`);
      pluginValid = false;
    } else {
      // Array can be file paths (strings) or agent objects
      for (const [index, agent] of manifest.agents.entries()) {
        if (typeof agent === 'string') {
          // File path to markdown agent file
          if (!agent.startsWith('./')) {
            error(`${pluginName}/.claude-plugin/plugin.json agent #${index + 1} path must start with './'`);
            pluginValid = false;
          } else {
            const agentPath = join(pluginDir, agent);
            if (!existsSync(agentPath)) {
              error(`${pluginName}/.claude-plugin/plugin.json agent file does not exist: ${agent}`);
              pluginValid = false;
            } else {
              success(`Agent file exists: ${agent}`);
            }
          }
        } else {
          // Inline agent object
          if (!agent.name) {
            error(`${pluginName}/.claude-plugin/plugin.json agent #${index + 1} missing name`);
            pluginValid = false;
          }
          if (!agent.description) {
            warn(`${pluginName}/.claude-plugin/plugin.json agent "${agent.name}" missing description`);
          }
          if (!agent.prompt) {
            error(`${pluginName}/.claude-plugin/plugin.json agent "${agent.name}" missing prompt`);
            pluginValid = false;
          }
        }
      }
    }
  }

  // Validate skills if present
  if (manifest.skills) {
    if (typeof manifest.skills === 'string') {
      // Skills defined in an external directory
      if (!manifest.skills.startsWith('./')) {
        error(`${pluginName}/.claude-plugin/plugin.json skills path must start with './'`);
        pluginValid = false;
      }
      const skillsPath = join(pluginDir, manifest.skills);
      if (!existsSync(skillsPath)) {
        error(`${pluginName}/.claude-plugin/plugin.json skills path does not exist: ${manifest.skills}`);
        pluginValid = false;
      }
    } else if (Array.isArray(manifest.skills)) {
      for (const [index, skill] of manifest.skills.entries()) {
        if (typeof skill === 'string') {
          if (!skill.startsWith('./')) {
            error(`${pluginName}/.claude-plugin/plugin.json skill #${index + 1} path must start with './'`);
            pluginValid = false;
          } else {
            const skillPath = join(pluginDir, skill);
            if (!existsSync(skillPath)) {
              error(`${pluginName}/.claude-plugin/plugin.json skill file does not exist: ${skill}`);
              pluginValid = false;
            } else {
              success(`Skill file exists: ${skill}`);
            }
          }
        }
      }
    }
  }

  if (pluginValid) {
    success(`Plugin ${pluginName} manifest is valid`);
  }

  return pluginValid;
}

// Check for README
function checkPluginReadme(pluginDir: string, pluginName: string): boolean {
  const readmePath = join(pluginDir, 'README.md');
  if (!existsSync(readmePath)) {
    warn(`Plugin ${pluginName} missing README.md`);
    return false;
  } else {
    success(`Plugin ${pluginName} has README.md`);
    return true;
  }
}

// Main linting
function main(): void {
  console.log('🔍 Linting Plugin Manifests\n');

  if (!existsSync(PLUGINS_DIR)) {
    info('No plugins directory found, skipping plugin linting');
    process.exit(0);
  }

  const entries = readdirSync(PLUGINS_DIR);
  const pluginDirs = entries.filter(entry => {
    const fullPath = join(PLUGINS_DIR, entry);
    return statSync(fullPath).isDirectory();
  });

  if (pluginDirs.length === 0) {
    info('No plugins found in plugins directory');
    process.exit(0);
  }

  info(`Found ${pluginDirs.length} plugin(s) to validate\n`);

  for (const pluginName of pluginDirs) {
    const pluginDir = join(PLUGINS_DIR, pluginName);
    console.log(`\n📦 Validating plugin: ${pluginName}`);
    console.log('─'.repeat(50));

    validatePluginManifest(pluginDir, pluginName);
    checkPluginReadme(pluginDir, pluginName);
  }

  // Summary
  console.log('\n' + '='.repeat(50));
  if (hasErrors) {
    console.log(`❌ Linting failed with errors (${warnings} warning(s))`);
    process.exit(1);
  } else if (warnings > 0) {
    console.log(`✅ Linting passed with ${warnings} warning(s)`);
    process.exit(0);
  } else {
    console.log('✅ All plugins passed linting');
    process.exit(0);
  }
}

main();
