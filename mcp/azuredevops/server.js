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

function cliFieldValue(v) {
  // `az boards work-item update --fields` expects strings; keep JSON-y values compact.
  if (v === null || v === undefined) return "";
  if (typeof v === "string") return v;
  if (typeof v === "number" || typeof v === "boolean") return String(v);
  return JSON.stringify(v);
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

async function azAccountUser() {
  const { stdout } = await runAz(["account", "show", "--query", "user.name", "-o", "tsv"]);
  return String(stdout ?? "").trim() || null;
}

async function azdoWorkItemShowFields({ id, orgUrl, project, fields }) {
  const env = azEnv({ orgUrl, project });
  const args = ["boards", "work-item", "show", "--id", String(id), "--expand", "none", "-o", "json"];
  if (fields && fields.length > 0) {
    args.push("--fields", fields.join(","));
  }
  const { stdout } = await runAz(args, { env });
  return asJson(stdout);
}

function getAssignedUniqueName(workItem) {
  const f = workItem?.fields ?? {};
  const a = f["System.AssignedTo"];
  if (!a) return null;
  if (typeof a === "string") return a; // sometimes displayName only
  // Azure DevOps often returns identity object.
  return a.uniqueName ?? a.mail ?? a.email ?? a.displayName ?? null;
}

async function ensureAssignedToMe({ id, orgUrl, project }) {
  const me = await azAccountUser();
  const wi = await azdoWorkItemShowFields({
    id,
    orgUrl,
    project,
    fields: ["System.AssignedTo", "System.Title", "System.WorkItemType", "System.State"],
  });
  const assigned = getAssignedUniqueName(wi);

  // Best-effort match:
  // - if we have an email, match by inclusion/equals ignoring case
  // - else allow (cannot safely verify)
  if (me && assigned) {
    const a = String(assigned).toLowerCase();
    const m = String(me).toLowerCase();
    if (!(a === m || a.includes(m) || m.includes(a))) {
      const title = wi?.fields?.["System.Title"];
      const type = wi?.fields?.["System.WorkItemType"];
      const state = wi?.fields?.["System.State"];
      const msg =
        `Work item #${id} no está asignado a @Me.\n` +
        `- AssignedTo: ${assigned}\n` +
        `- Me: ${me}\n` +
        (type || title || state
          ? `- Work item: ${type ?? "?"} — ${title ?? "?"} (${state ?? "?"})\n`
          : "");
      const err = new Error(msg.trim());
      err.code = "NOT_ASSIGNED_TO_ME";
      throw err;
    }
  }

  return { me, workItem: wi };
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

// Default team for "current sprint" filters when none is provided explicitly.
// Can be overridden with env AZDO_TEAM or tool arg `team`.
const DEFAULT_TEAM = "(Asulado) SmartPay";

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
  "azdo_work_item_update",
  {
    id: z.number().int().positive().describe("Work item ID (numérico)."),
    orgUrl: z.string().optional().describe("Ej: https://dev.azure.com/Asulado"),
    project: z.string().optional().describe("Nombre exacto del proyecto"),
    // Safety rails
    confirm: z
      .boolean()
      .optional()
      .describe("Debe ser true para ejecutar la actualización (default: false)."),
    onlyIfAssignedToMe: z
      .boolean()
      .optional()
      .describe("Si true, solo actualiza si el work item está asignado a @Me (default: true)."),
    // Updates
    state: z.string().optional().describe("Nuevo estado (ej: Active, En Desarrollo, Closed)."),
    title: z.string().optional().describe("Nuevo título."),
    iteration: z.string().optional().describe("Nuevo IterationPath."),
    reason: z.string().optional().describe("Reason del cambio de estado (si aplica)."),
    discussion: z.string().optional().describe("Comentario para Discussion."),
    description: z.string().optional().describe("Descripción (HTML o texto)."),
    fields: z
      .array(
        z.object({
          name: z.string().min(1),
          value: z.any(),
        }),
      )
      .optional()
      .describe(
        "Campos adicionales (ej: Microsoft.VSTS.Scheduling.RemainingWork, OriginalEstimate, CompletedWork, etc.).",
      ),
  },
  async ({ id, orgUrl, project, confirm, onlyIfAssignedToMe, state, title, iteration, reason, discussion, description, fields }) => {
    const _confirm = confirm ?? false;
    const _onlyIfAssignedToMe = onlyIfAssignedToMe ?? true;
    if (!_confirm) {
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(
              { error: "Confirmation required. Re-run with confirm=true to update the work item." },
              null,
              2,
            ),
          },
        ],
      };
    }

    if (_onlyIfAssignedToMe) {
      await ensureAssignedToMe({ id, orgUrl, project });
    }

    const args = ["boards", "work-item", "update", "--id", String(id)];
    if (state) args.push("--state", state);
    if (title) args.push("--title", title);
    if (iteration) args.push("--iteration", iteration);
    if (reason) args.push("--reason", reason);
    if (discussion) args.push("--discussion", discussion);
    if (description) args.push("--description", description);

    if (fields && Array.isArray(fields) && fields.length > 0) {
      args.push("--fields");
      for (const f of fields) {
        if (!f?.name) continue;
        args.push(`${f.name}=${cliFieldValue(f.value)}`);
      }
    }

    const { stdout } = await runAz(args.concat(["-o", "json"]), { env: azEnv({ orgUrl, project }) });
    const obj = asJson(stdout);
    return { content: [{ type: "text", text: JSON.stringify(obj, null, 2) }] };
  },
);

server.tool(
  "azdo_work_item_create",
  {
    orgUrl: z.string().optional().describe("Ej: https://dev.azure.com/Asulado"),
    project: z.string().optional().describe("Nombre exacto del proyecto"),
    confirm: z
      .boolean()
      .optional()
      .describe("Debe ser true para ejecutar la creación (default: false)."),
    onlyAssignToMe: z
      .boolean()
      .optional()
      .describe("Si true, fuerza assignedTo=@Me (default: true)."),
    type: z
      .enum(["Task", "User Story"])
      .optional()
      .describe("Tipo de work item (default: Task)."),
    title: z.string().min(1).describe("Título."),
    description: z.string().optional().describe("Descripción (HTML o texto)."),
    discussion: z.string().optional().describe("Comentario para Discussion."),
    iteration: z.string().optional().describe("IterationPath (si no se pasa, usa sprint actual del team default)."),
    team: z.string().optional().describe("Team para resolver sprint actual si iteration no se pasa."),
    fields: z
      .array(
        z.object({
          name: z.string().min(1),
          value: z.any(),
        }),
      )
      .optional()
      .describe("Campos adicionales (field=value)."),
  },
  async ({ orgUrl, project, confirm, onlyAssignToMe, type, title, description, discussion, iteration, team, fields }) => {
    const _confirm = confirm ?? false;
    if (!_confirm) {
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(
              { error: "Confirmation required. Re-run with confirm=true to create the work item." },
              null,
              2,
            ),
          },
        ],
      };
    }

    const _onlyAssignToMe = onlyAssignToMe ?? true;
    const _type = type ?? "Task";

    const args = ["boards", "work-item", "create", "--type", _type, "--title", title];
    if (description) args.push("--description", description);
    if (discussion) args.push("--discussion", discussion);

    let iterationPath = iteration ?? null;
    if (!iterationPath) {
      const effectiveTeam = team ?? process.env.AZDO_TEAM ?? DEFAULT_TEAM;
      iterationPath = await azdoCurrentIterationPath({ orgUrl, project, team: effectiveTeam });
    }
    if (iterationPath) args.push("--iteration", iterationPath);

    if (_onlyAssignToMe) {
      // Azure DevOps CLI supports --assigned-to; using @Me isn't always accepted here, so use email.
      const me = await azAccountUser();
      if (me) args.push("--assigned-to", me);
    }

    if (fields && Array.isArray(fields) && fields.length > 0) {
      args.push("--fields");
      for (const f of fields) {
        if (!f?.name) continue;
        args.push(`${f.name}=${cliFieldValue(f.value)}`);
      }
    }

    const { stdout } = await runAz(args.concat(["-o", "json"]), { env: azEnv({ orgUrl, project }) });
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

    const effectiveTeam = team ?? process.env.AZDO_TEAM ?? DEFAULT_TEAM;
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

    const { stdout } = await runAz(["boards", "query", "--wiql", wiql, "-o", "json"], {
      env: azEnv({ orgUrl, project }),
    });
    const obj = asJson(stdout);
    const sliced = Array.isArray(obj) ? obj.slice(0, _top) : obj;
    return { content: [{ type: "text", text: JSON.stringify(sliced, null, 2) }] };
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
    const effectiveTeam = team ?? process.env.AZDO_TEAM ?? DEFAULT_TEAM;
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
