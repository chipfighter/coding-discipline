#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / "plugins" / "coding-discipline"
SEMVER = re.compile(r"^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$")
HAN = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff]")
# agentskills.io constrains the two fields every host reads. Claude Code is
# lenient about both, so a violation keeps working here and fails silently
# wherever else the skills directory is copied.
SKILL_NAME = re.compile(r"[a-z0-9]+(?:-[a-z0-9]+)*")
SKILL_NAME_MAX = 64
SKILL_DESCRIPTION_MAX = 1024
# Retain the existing context ceiling. With no session primer, only the
# skill descriptions contribute to this check.
FIXED_CONTEXT_BUDGET = 4580
AUTOMATIC_SKILLS = {"spec-sync", "systematic-debugging"}
MANUAL_SKILLS = {"brainstorming", "tdd"}
CLAUDE_MANUAL = re.compile(r"^disable-model-invocation:[ \t]+true[ \t]*$", re.MULTILINE)
CODEX_MANUAL = re.compile(
    r"^policy:[ \t]*\n(?:[ \t]+[^\n]*\n)*?"
    r"[ \t]+allow_implicit_invocation:[ \t]+false[ \t]*$",
    re.MULTILINE,
)


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
assert (PLUGIN / manifest["skills"]).resolve() == PLUGIN / "skills"
assert "hooks" not in manifest, "Codex must not register hooks"
assert "hooks" not in claude_manifest, "Claude Code must not register hooks"
assert not list(PLUGIN.glob("hooks/*")), "no hooks may ship with the plugin"
assert not (PLUGIN / "templates" / "agent-doc.seed.md").exists()

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

claude_marketplace = load_json(ROOT / ".claude-plugin" / "marketplace.json")
claude_entry = next(item for item in claude_marketplace["plugins"] if item["name"] == manifest["name"])
assert claude_entry["source"] == entry["source"]["path"]

skills = sorted((PLUGIN / "skills").glob("*/SKILL.md"))
assert {path.parent.name for path in skills} == AUTOMATIC_SKILLS | MANUAL_SKILLS
description_chars = 0
for path in skills:
    text = path.read_text(encoding="utf-8")
    assert text.startswith("---\n"), f"{path} has no frontmatter"
    frontmatter = text.split("\n---\n", 1)[0]
    name = re.search(r"(?m)^name:\s*(\S+)\s*$", frontmatter)
    description = re.search(r"(?m)^description:\s*(.+)\s*$", frontmatter)
    assert name and name.group(1) == path.parent.name, f"{path} has the wrong name"
    assert description, f"{path} has no description"
    assert SKILL_NAME.fullmatch(name.group(1)), f"{path} name is not portable"
    assert len(name.group(1)) <= SKILL_NAME_MAX, f"{path} name is too long"
    assert len(description.group(1)) <= SKILL_DESCRIPTION_MAX, (
        f"{path} description exceeds the {SKILL_DESCRIPTION_MAX}-char spec limit"
    )
    # The skills directory is documented as copyable on its own, so each file
    # has to carry its own licence rather than rely on the repository root.
    licence = re.search(r"(?m)^license:\s*(.+?)\s*$", frontmatter)
    assert licence and licence.group(1) == "MIT", f"{path} has no license: MIT"

    manual = path.parent.name in MANUAL_SKILLS
    assert bool(CLAUDE_MANUAL.search(frontmatter)) == manual, f"{path} has the wrong Claude routing"
    codex_policy = path.parent / "agents" / "openai.yaml"
    metadata = codex_policy.read_text(encoding="utf-8") if codex_policy.is_file() else ""
    assert bool(CODEX_MANUAL.search(metadata)) == manual, f"{path} has the wrong Codex routing"
    description_chars += len(description.group(1))

assert description_chars <= FIXED_CONTEXT_BUDGET, (
    f"fixed context grew to {description_chars} chars "
    f"(budget {FIXED_CONTEXT_BUDGET} = frozen v0.8.0 English baseline)"
)

# v0.8.0 makes the active product surface English-only. The one maintained
# Chinese translation is explicitly excluded.
text_extensions = {".cmd", ".json", ".md", ".ps1", ".py", ".sh", ".yml", ".yaml"}
extensionless_text = {
    ".gitattributes",
    ".gitignore",
}
tracked_files = subprocess.check_output(
    ["git", "ls-files"],
    cwd=ROOT,
    text=True,
).splitlines()
for relative in tracked_files:
    if relative == "README.zh-CN.md":
        continue
    path = ROOT / relative
    if not path.is_file():
        continue
    if path.suffix not in text_extensions and path.name not in extensionless_text:
        continue
    text = path.read_text(encoding="utf-8")
    match = HAN.search(text)
    assert not match, f"{relative} contains Han text outside README.zh-CN.md"

print("plugin metadata tests passed")
