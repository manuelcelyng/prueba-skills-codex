#!/usr/bin/env node
/**
 * MCP server: Azure DevOps Boards (Work Items)
 *
 * Auth model:
 * - Uses local Azure CLI auth:
 *   - `az login --allow-no-subscriptions` (AAD/MFA), or
 *   - `az devops login --organization ...` (PAT)
 * - Azure DevOps extension is required:
 *   - `az extension add --name azure-devops`
 *
 * IMPORTANT:
 * - Never write logs to stdout (reserved for JSON-RPC). Use stderr.
 */

import { spawn } from "node:child_process";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

function wiqlEscape(s) {
  return String(s ?? "").replaceAll("'", "''");
}

function runAz(args, { env } = {}) {
  return new Promise((resolve, reject) => {
    const p = spawn("az", args, {
      env: { ...process.env, ...(env ?? {}) },
      stdio: ["ignore", "pipe", "pipe"],
    });

    let stdout = "";
    let stderr = "";
    p.stdout.setEncoding("utf8");
    p.stderr.setEncoding("utf8");
    p.stdout.on("data", (d) => (stdout += d));
    p.stderr.on("data", (d) => (stderr += d));
    p.on("error", reject);
    p.on("close", (code) => {
      if (code === 0) return resolve({ stdout, stderr });
      const err = new Error(`az ${args.join(" ")} failed with code ${code}\n${stderr}`.trim());
      err.code = code;
      reject(err);
    });
  });
}

function azEnv({ orgUrl, project }) {
  const env = {};
  if (orgUrl) env.AZURE_DEVOPS_EXT_ORG_SERVICE_URL = orgUrl;
  if (project) env.AZURE_DEVOPS_EXT_PROJECT = project;
  return env;
}

function asJson(text) {
  const t = (text ?? "").trim();
  if (!t) return null;
  return JSON.parse(t);
}

async function azdoCurrentIterationPath({ orgUrl, project, team }) {
  if (!team) return null;
  const { stdout } = await runAz(
    ["boards", "iteration", "team", "list", "--team", team, "--timeframe", "Current", "-o", "json"],
    { env: azEnv({ orgUrl, project }) },
  );
  const arr = asJson(stdout);
  if (!Array.isArray(arr) || arr.length === 0) return null;
  // Prefer an explicit path field when present.
  const first = arr[0] ?? {};
  return first.path ?? first.name ?? null;
}

const server = new McpServer({
  name: "azuredevops",
  version: "0.1.0",
});

server.tool(
  "azdo_work_item_show",
  {
    id: z.number().int().positive().describe("Work item ID (numérico)."),
    expand: z
      .enum(["none", "relations", "fields", "links", "all"])
      .optional()
      .describe("Nivel de expansión (default: relations)."),
    orgUrl: z.string().optional().describe("Ej: https://dev.azure.com/Asulado"),
    project: z.string().optional().describe("Nombre exacto del proyecto"),
  },
  async ({ id, expand, orgUrl, project }) => {
    const { stdout } = await runAz(
      ["boards", "work-item", "show", "--id", String(id), "--expand", expand ?? "relations", "-o", "json"],
      { env: azEnv({ orgUrl, project }) },
    );
    const obj = asJson(stdout);
    return { content: [{ type: "text", text: JSON.stringify(obj, null, 2) }] };
  },
);

server.tool(
  "azdo_query_wiql",
  {
    wiql: z.string().min(1).describe("Query WIQL completa."),
    orgUrl: z.string().optional().describe("Ej: https://dev.azure.com/Asulado"),
    project: z.string().optional().describe("Nombre exacto del proyecto"),
  },
  async ({ wiql, orgUrl, project }) => {
    const { stdout } = await runAz(["boards", "query", "--wiql", wiql, "-o", "json"], {
      env: azEnv({ orgUrl, project }),
    });
    const obj = asJson(stdout);
    return { content: [{ type: "text", text: JSON.stringify(obj, null, 2) }] };
  },
);

server.tool(
  "azdo_list_my_work_items",
  {
    orgUrl: z.string().optional().describe("Ej: https://dev.azure.com/Asulado"),
    project: z.string().optional().describe("Nombre exacto del proyecto"),
    team: z
      .string()
      .optional()
      .describe("Nombre o id del team (necesario para filtrar por sprint/iteración actual)."),
    onlyCurrentSprint: z
      .boolean()
      .optional()
      .describe("Si true, filtra por la iteración actual del team (default: true)."),
    top: z.number().int().positive().max(200).optional().describe("Máximo de resultados (default: 50)."),
    statesNotIn: z.array(z.string()).optional().describe("Estados a excluir (default: ['Done', 'Closed', 'Removed'])."),
    workItemTypes: z
      .array(z.string())
      .optional()
      .describe("Tipos a incluir (default: ['Task','Bug','User Story'])."),
  },
  async ({ orgUrl, project, team, onlyCurrentSprint, top, statesNotIn, workItemTypes }) => {
    const _top = top ?? 50;
    const _statesNotIn = statesNotIn ?? ["Done", "Closed", "Removed"];
    const _types = workItemTypes ?? ["Task", "Bug", "User Story"];
    const _onlyCurrentSprint = onlyCurrentSprint ?? true;

    const effectiveTeam = team ?? process.env.AZDO_TEAM ?? null;
    let iterationPath = null;
    if (_onlyCurrentSprint && effectiveTeam) {
      iterationPath = await azdoCurrentIterationPath({ orgUrl, project, team: effectiveTeam });
    }

    const notInStates = _statesNotIn.map((s) => `'${wiqlEscape(s)}'`).join(", ");
    const inTypes = _types.map((t) => `'${wiqlEscape(t)}'`).join(", ");

    const wiql =
      "SELECT [System.Id], [System.WorkItemType], [System.Title], [System.State], [System.ChangedDate] " +
      "FROM WorkItems " +
      "WHERE [System.AssignedTo] = @Me " +
      `AND [System.State] NOT IN (${notInStates}) ` +
      `AND [System.WorkItemType] IN (${inTypes}) ` +
      (iterationPath ? `AND [System.IterationPath] = '${wiqlEscape(iterationPath)}' ` : "") +
      "ORDER BY [System.ChangedDate] DESC";

    const { stdout } = await runAz(["boards", "query", "--wiql", wiql, "--top", String(_top), "-o", "json"], {
      env: azEnv({ orgUrl, project }),
    });
    const obj = asJson(stdout);
    return { content: [{ type: "text", text: JSON.stringify(obj, null, 2) }] };
  },
);

server.tool(
  "azdo_current_iteration",
  {
    orgUrl: z.string().optional().describe("Ej: https://dev.azure.com/Asulado"),
    project: z.string().optional().describe("Nombre exacto del proyecto"),
    team: z.string().optional().describe("Nombre o id del team (si no se pasa, usa env AZDO_TEAM)."),
  },
  async ({ orgUrl, project, team }) => {
    const effectiveTeam = team ?? process.env.AZDO_TEAM ?? null;
    if (!effectiveTeam) {
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({ error: "Missing team. Pass `team` or set env AZDO_TEAM." }, null, 2),
          },
        ],
      };
    }
    const { stdout } = await runAz(
      ["boards", "iteration", "team", "list", "--team", effectiveTeam, "--timeframe", "Current", "-o", "json"],
      { env: azEnv({ orgUrl, project }) },
    );
    const obj = asJson(stdout);
    return { content: [{ type: "text", text: JSON.stringify(obj, null, 2) }] };
  },
);

async function main() {
  try {
    const transport = new StdioServerTransport();
    await server.connect(transport);
  } catch (e) {
    // eslint-disable-next-line no-console
    console.error(String(e?.stack ?? e));
    process.exit(1);
  }
}

await main();
