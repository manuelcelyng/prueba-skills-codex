#!/usr/bin/env python3
"""
Fetch Azure DevOps work item context (work item JSON + relations + attachments) and render context.md.

Assumptions:
- `az` is installed and authenticated (AAD via `az login --allow-no-subscriptions` OR `az devops login` with PAT).
- Azure DevOps extension is installed (`az extension add --name azure-devops`).
"""

from __future__ import annotations

import argparse
import html
import json
import os
import re
import shutil
import ssl
import subprocess
import sys
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Set, Tuple


AZDO_RESOURCE = "499b84ac-1321-427f-aa17-267ca6975798"  # Azure DevOps


def run(cmd: List[str], *, env: Optional[Dict[str, str]] = None) -> str:
    p = subprocess.run(
        cmd,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        env=env,
    )
    return p.stdout


def az_env(org_url: Optional[str], project: Optional[str]) -> Dict[str, str]:
    env = dict(os.environ)
    if org_url:
        env["AZURE_DEVOPS_EXT_ORG_SERVICE_URL"] = org_url
    if project:
        env["AZURE_DEVOPS_EXT_PROJECT"] = project
    return env


def az_boards_show(work_item_id: int, *, expand: str, env: Dict[str, str]) -> Dict[str, Any]:
    out = run(
        ["az", "boards", "work-item", "show", "--id", str(work_item_id), "--expand", expand, "--output", "json"],
        env=env,
    )
    return json.loads(out)


def get_bearer_token() -> str:
    # Use AAD token for Azure DevOps resource; works even when there are no Azure subscriptions.
    out = run(
        ["az", "account", "get-access-token", "--resource", AZDO_RESOURCE, "--query", "accessToken", "-o", "tsv"]
    )
    return out.strip()


def download_with_bearer(url: str, bearer: str, out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {bearer}"})
    opener = urllib.request.build_opener(urllib.request.HTTPRedirectHandler())
    try:
        with opener.open(req) as resp, open(out_path, "wb") as f:
            shutil.copyfileobj(resp, f)
        return
    except Exception as e:
        # Common on some macOS Python installs: missing/invalid CA bundle -> CERTIFICATE_VERIFY_FAILED.
        # Fallback to curl (system trust store) when available.
        if shutil.which("curl") and (
            isinstance(e, ssl.SSLError)
            or "CERTIFICATE_VERIFY_FAILED" in str(e)
            or "certificate verify failed" in str(e).lower()
        ):
            subprocess.run(
                ["curl", "-L", "-sS", "-H", f"Authorization: Bearer {bearer}", "-o", str(out_path), url],
                check=True,
            )
            return
        raise


def html_to_text(s: str) -> str:
    if not s:
        return ""
    s = s.replace("\r", "")
    s = re.sub(r"<\s*br\s*/?>", "\n", s, flags=re.I)
    s = re.sub(r"</\s*p\s*>", "\n", s, flags=re.I)
    s = re.sub(r"</\s*div\s*>", "\n", s, flags=re.I)
    s = re.sub(r"<\s*li\b[^>]*>", "\n- ", s, flags=re.I)
    s = re.sub(r"</\s*li\s*>", "", s, flags=re.I)
    s = re.sub(r"<\s*ul\b[^>]*>", "\n", s, flags=re.I)
    s = re.sub(r"</\s*ul\s*>", "\n", s, flags=re.I)
    s = re.sub(r"<[^>]+>", "", s)
    s = html.unescape(s)
    s = re.sub(r"[ \t\xa0]+", " ", s)
    s = re.sub(r"\n\s*\n\s*\n+", "\n\n", s)
    return s.strip()


def extract_related_ids(relations: Optional[List[Dict[str, Any]]]) -> Tuple[Set[int], List[Dict[str, Any]]]:
    ids: Set[int] = set()
    attachments: List[Dict[str, Any]] = []
    for rel in relations or []:
        url = rel.get("url", "")
        if rel.get("rel") == "AttachedFile":
            attachments.append(rel)
            continue
        m = re.search(r"/workItems/(\d+)$", url)
        if m:
            ids.add(int(m.group(1)))
    return ids, attachments


def safe_filename(name: str) -> str:
    # Keep as-is but strip path separators.
    return name.replace("/", "_").replace("\\", "_").strip()


def attachment_download_url(base_url: str, filename: str) -> str:
    # base_url is like .../_apis/wit/attachments/<guid>
    q = urllib.parse.urlencode({"fileName": filename, "api-version": "7.1"}, quote_via=urllib.parse.quote)
    sep = "&" if "?" in base_url else "?"
    return f"{base_url}{sep}{q}"


def docx_to_txt_if_possible(docx_path: Path) -> Optional[Path]:
    if docx_path.suffix.lower() != ".docx":
        return None
    if shutil.which("textutil") is None:
        return None
    txt_path = docx_path.with_suffix(".txt")
    # macOS: textutil can convert .docx to plain text.
    with open(txt_path, "w", encoding="utf-8") as f:
        subprocess.run(["textutil", "-convert", "txt", "-stdout", str(docx_path)], check=True, stdout=f)
    return txt_path


def render_context_md(
    work_item: Dict[str, Any],
    related_items: List[Dict[str, Any]],
    attachment_files: List[Path],
    out_path: Path,
) -> None:
    f = work_item.get("fields", {})

    def fget(key: str) -> Any:
        return f.get(key)

    assigned = fget("System.AssignedTo") or {}
    if isinstance(assigned, dict):
        assigned_name = assigned.get("displayName")
    else:
        assigned_name = str(assigned)

    lines: List[str] = []
    lines.append(f"# Contexto HU {work_item.get('id')} — {fget('System.Title')}")
    lines.append("")
    lines.append("## Metadatos")
    lines.append(f"- **Work item**: {work_item.get('id')} ({fget('System.WorkItemType')})")
    lines.append(f"- **Título**: {fget('System.Title')}")
    lines.append(f"- **Estado**: {fget('System.State')}")
    if fget("System.AreaPath"):
        lines.append(f"- **Área**: {fget('System.AreaPath')}")
    if fget("System.IterationPath"):
        lines.append(f"- **Iteración**: {fget('System.IterationPath')}")
    if fget("Microsoft.VSTS.Common.Priority") is not None:
        lines.append(f"- **Prioridad**: {fget('Microsoft.VSTS.Common.Priority')}")
    if fget("Microsoft.VSTS.Scheduling.OriginalEstimate") is not None:
        lines.append(f"- **Estimación original (h)**: {fget('Microsoft.VSTS.Scheduling.OriginalEstimate')}")
    if fget("System.CreatedDate"):
        lines.append(f"- **Creado**: {fget('System.CreatedDate')}")
    if fget("Microsoft.VSTS.Common.ActivatedDate"):
        lines.append(f"- **Activado**: {fget('Microsoft.VSTS.Common.ActivatedDate')}")
    if fget("System.ChangedDate"):
        lines.append(f"- **Último cambio**: {fget('System.ChangedDate')}")
    if fget("Microsoft.VSTS.Common.StateChangeDate"):
        lines.append(f"- **Cambio de estado**: {fget('Microsoft.VSTS.Common.StateChangeDate')}")
    if assigned_name:
        lines.append(f"- **Asignado a**: {assigned_name}")

    lines.append("")
    lines.append("## Descripción (texto plano)")
    lines.append(html_to_text(fget("System.Description") or ""))

    lines.append("")
    lines.append("## Criterios de aceptación (texto plano)")
    lines.append(html_to_text(fget("Microsoft.VSTS.Common.AcceptanceCriteria") or ""))

    lines.append("")
    lines.append("## Anexos (descargados)")
    if attachment_files:
        for p in attachment_files:
            lines.append(f"- `{p}`")
    else:
        lines.append("- (Sin anexos)")

    lines.append("")
    lines.append("## Work items relacionados (descargados)")
    if not related_items:
        lines.append("- (Sin relaciones)")
    else:
        for it in related_items:
            rf = it.get("fields", {})
            lines.append(
                f"- **#{it.get('id')}** — {rf.get('System.Title')} "
                f"({rf.get('System.WorkItemType')}) — {rf.get('System.State')}"
            )

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def parse_work_item_id_from_link(s: str) -> Optional[int]:
    # Example: .../_workitems/edit/25459
    m = re.search(r"/_workitems/edit/(\d+)", s)
    return int(m.group(1)) if m else None


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--id", type=int, help="Work item ID (si no viene, intenta extraerlo de --link).")
    ap.add_argument("--link", help="Link del work item (opcional).")
    ap.add_argument("--org-url", dest="org_url", help="Ej: https://dev.azure.com/Asulado")
    ap.add_argument("--project", help="Nombre exacto del proyecto")
    ap.add_argument("--repo-root", default=os.getcwd(), help="Ruta del repo donde escribir context/ (default: cwd)")
    ap.add_argument("--out-dir", help="Override del directorio de salida (default: context/hu-<id>)")
    ap.add_argument("--no-attachments", action="store_true", help="No descargar anexos.")
    ap.add_argument("--no-related", action="store_true", help="No descargar work items relacionados.")
    args = ap.parse_args()

    work_item_id = args.id
    if not work_item_id and args.link:
        work_item_id = parse_work_item_id_from_link(args.link)
    if not work_item_id:
        print("ERROR: Debes pasar --id o --link con un id válido.", file=sys.stderr)
        return 2

    repo_root = Path(args.repo_root).resolve()
    out_dir = Path(args.out_dir).resolve() if args.out_dir else (repo_root / "context" / f"hu-{work_item_id}")
    attachments_dir = out_dir / "attachments"
    related_dir = out_dir / "related-workitems"

    env = az_env(args.org_url, args.project)

    # 1) Main work item with relations for attachments & relation ids
    work_item = az_boards_show(work_item_id, expand="relations", env=env)
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / f"{work_item_id}.json").write_text(json.dumps(work_item, indent=2, ensure_ascii=False) + "\n", "utf-8")

    related_ids, attachments = extract_related_ids(work_item.get("relations"))

    # 2) Related work items JSON
    related_items: List[Dict[str, Any]] = []
    if not args.no_related and related_ids:
        related_dir.mkdir(parents=True, exist_ok=True)
        for rid in sorted(related_ids):
            try:
                d = az_boards_show(rid, expand="none", env=env)
                related_items.append(d)
                (related_dir / f"{rid}.json").write_text(json.dumps(d, indent=2, ensure_ascii=False) + "\n", "utf-8")
            except subprocess.CalledProcessError as e:
                print(f"WARN: no pude bajar work item relacionado #{rid}: {e.stderr}", file=sys.stderr)

    # 3) Attachments
    attachment_files: List[Path] = []
    if not args.no_attachments and attachments:
        bearer = get_bearer_token()
        attachments_dir.mkdir(parents=True, exist_ok=True)
        for a in attachments:
            attrs = a.get("attributes", {}) or {}
            name = attrs.get("name")
            base_url = a.get("url")
            if not name or not base_url:
                continue
            safe = safe_filename(name)
            out_path = attachments_dir / safe
            # Use the original filename for the API query param; use a sanitized name only for local disk.
            url = attachment_download_url(base_url, name)
            try:
                download_with_bearer(url, bearer, out_path)
                attachment_files.append(out_path)
                txt = docx_to_txt_if_possible(out_path)
                if txt:
                    attachment_files.append(txt)
            except Exception as e:
                print(f"WARN: no pude bajar anexo '{name}': {e}", file=sys.stderr)

    # 4) Render context.md
    render_context_md(work_item, related_items, attachment_files, out_dir / "context.md")
    print(str(out_dir / "context.md"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
