#!/usr/bin/env node

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { readdir, readFile } from "node:fs/promises";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SKILLS_DIR = join(__dirname, "..", "claude", "nox");
const AGENTS_DIR = join(__dirname, "..", "agents");

// Discover skills dynamically from filesystem
async function discoverSkills() {
  const skills = new Map();
  try {
    const files = await readdir(SKILLS_DIR);
    for (const file of files) {
      if (file.endsWith(".md")) {
        const name = file.replace(/\.md$/, "");
        skills.set(name, join(SKILLS_DIR, file));
      }
    }
  } catch {
    // Skills dir missing — empty catalog
  }
  return skills;
}

// Discover agents dynamically from filesystem
async function discoverAgents() {
  const agents = new Map();
  try {
    const files = await readdir(AGENTS_DIR);
    for (const file of files) {
      if (file.startsWith("nox-") && file.endsWith(".md")) {
        const name = file.replace(/\.md$/, "");
        agents.set(name, join(AGENTS_DIR, file));
      }
    }
  } catch {
    // Agents dir missing — empty catalog
  }
  return agents;
}

async function main() {
  const skills = await discoverSkills();
  const agents = await discoverAgents();

  const skillNames = [...skills.keys()];
  const agentNames = [...agents.keys()];

  const server = new McpServer({
    name: "nox",
    version: "1.5.0",
  });

  // Tool 1: List all skills (returns help-forge catalog)
  server.tool(
    "nox_list",
    "List all available Nox skills and agents. Returns the full skill catalog.",
    {},
    async () => {
      const helpForgePath = skills.get("help-forge");
      if (!helpForgePath) {
        return { content: [{ type: "text", text: "help-forge.md not found. Skills directory may be missing." }] };
      }
      const content = await readFile(helpForgePath, "utf-8");
      return { content: [{ type: "text", text: content }] };
    }
  );

  // Tool 2: Get a specific skill's instructions
  server.tool(
    "nox_skill",
    "Get the full instructions for a Nox skill. The LLM should follow these instructions to execute the skill.",
    {
      skill_name: z.enum(skillNames).describe("The skill to retrieve (e.g. 'audit', 'deploy', 'security')"),
      mode: z.string().optional().describe("Optional mode to pass to the skill (e.g. 'pentest' for security)"),
      target: z.string().optional().describe("Optional target path or description for the skill to act on"),
    },
    async ({ skill_name, mode, target }) => {
      const skillPath = skills.get(skill_name);
      if (!skillPath) {
        return { content: [{ type: "text", text: `Skill '${skill_name}' not found.` }] };
      }
      let content = await readFile(skillPath, "utf-8");

      // Prepend context if mode or target provided
      const context = [];
      if (mode) context.push(`Mode: ${mode}`);
      if (target) context.push(`Target: ${target}`);
      if (context.length > 0) {
        content = `## Context\n${context.join("\n")}\n\n---\n\n${content}`;
      }

      return { content: [{ type: "text", text: content }] };
    }
  );

  // Tool 3: Get an agent definition
  server.tool(
    "nox_agent",
    "Get the full definition for a Nox agent. These are specialized subagents for quality gates.",
    {
      agent_name: z.enum(agentNames).describe("The agent to retrieve (e.g. 'nox-reviewer', 'nox-pentester')"),
    },
    async ({ agent_name }) => {
      const agentPath = agents.get(agent_name);
      if (!agentPath) {
        return { content: [{ type: "text", text: `Agent '${agent_name}' not found.` }] };
      }
      const content = await readFile(agentPath, "utf-8");
      return { content: [{ type: "text", text: content }] };
    }
  );

  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((err) => {
  console.error("Nox MCP server failed to start:", err);
  process.exit(1);
});
