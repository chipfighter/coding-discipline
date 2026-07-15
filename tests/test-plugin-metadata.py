#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / "plugins" / "coding-discipline"
SEMVER = re.compile(r"^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$")
V0_5_FIXED_CONTEXT_BUDGET = 1346


def load_json(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        payload = json.load(handle)
    assert isinstance(payload, dict), f"{path} must contain an object"
    return payload


manifest = load_json(PLUGIN / ".codex-plugin" / "plugin.json")
assert manifest["name"] == PLUGIN.name
assert SEMVER.fullmatch(manifest["version"])

claude_manifest = load_json(PLUGIN / ".claude-plugin" / "plugin.json")
assert claude_manifest["name"] == manifest["name"], "manifest names diverged"
assert claude_manifest["version"] == manifest["version"], "manifest versions diverged"
assert (PLUGIN / manifest["skills"]).is_dir()
assert (PLUGIN / manifest["hooks"]).is_file()

wrapper_path = "plugins/coding-discipline/hooks/run-hook.cmd"
wrapper_stage = subprocess.check_output(
    ["git", "ls-files", "--stage", "--", wrapper_path],
    cwd=ROOT,
    text=True,
).split()
assert wrapper_stage and wrapper_stage[0] == "100755", "run-hook.cmd must be executable on Unix"

interface = manifest["interface"]
for field in (
    "displayName",
    "shortDescription",
    "longDescription",
    "developerName",
    "category",
    "capabilities",
    "defaultPrompt",
):
    assert interface.get(field), f"missing interface.{field}"
assert len(interface["defaultPrompt"]) <= 3
assert all(len(prompt) <= 128 for prompt in interface["defaultPrompt"])

hooks = load_json(PLUGIN / "hooks" / "hooks-codex.json")
session = hooks["hooks"]["SessionStart"][0]
assert session["matcher"] == "startup|resume|clear|compact"
handler = session["hooks"][0]
assert handler["type"] == "command"
assert handler["command"].endswith("session-start-skills codex")
assert handler["commandWindows"].startswith("cmd.exe ")

marketplace = load_json(ROOT / ".agents" / "plugins" / "marketplace.json")
entry = next(item for item in marketplace["plugins"] if item["name"] == manifest["name"])
assert entry["source"] == {
    "source": "local",
    "path": "./plugins/coding-discipline",
}
assert entry["policy"] == {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL",
}
assert entry["category"]

skills = sorted((PLUGIN / "skills").glob("*/SKILL.md"))
assert len(skills) == 7
description_chars = 0
for path in skills:
    text = path.read_text(encoding="utf-8")
    assert text.startswith("---\n"), f"{path} has no frontmatter"
    frontmatter = text.split("\n---\n", 1)[0]
    name = re.search(r"(?m)^name:\s*(\S+)\s*$", frontmatter)
    description = re.search(r"(?m)^description:\s*(.+)\s*$", frontmatter)
    assert name and name.group(1) == path.parent.name, f"{path} has the wrong name"
    assert description, f"{path} has no description"
    description_chars += len(description.group(1))

primer_chars = len((PLUGIN / "hooks" / "skill-discipline.md").read_text(encoding="utf-8"))
fixed_context_chars = description_chars + primer_chars
assert fixed_context_chars <= V0_5_FIXED_CONTEXT_BUDGET, (
    f"fixed context grew to {fixed_context_chars} chars "
    f"(v0.5.0 baseline: {V0_5_FIXED_CONTEXT_BUDGET})"
)

print("plugin metadata tests passed")
