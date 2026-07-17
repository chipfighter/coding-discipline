#!/usr/bin/env python3
"""Measure the fixed per-session context cost of two Claude Code skill plugins.

Fixed context = everything a plugin adds to EVERY session before the user
types anything:

  1. SessionStart hook payload — the additionalContext text the hook emits
     (wrapper tags included, measured exactly as the host receives it).
  2. Skill metadata — the name + description lines Claude Code loads for
     every skill so it can route to them.

Both plugins are measured with the same rules. Skill bodies are excluded on
both sides: they load only when a skill triggers (progressive disclosure).

Usage:
  python measure_fixed_context.py <coding-discipline-repo> <superpowers-repo>

Reproduce:
  git clone https://github.com/chipfighter/coding-discipline
  git clone --depth 1 --branch v6.1.1 https://github.com/obra/superpowers
  python measure_fixed_context.py coding-discipline superpowers
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

TOKEN_CHARS = 4.0  # rough English chars-per-token; both sides use the same ratio


def frontmatter_meta(skill_md: Path) -> tuple[str, str]:
    text = skill_md.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        raise SystemExit(f"{skill_md}: no frontmatter")
    block = text.split("\n---\n", 1)[0]
    name = re.search(r"(?m)^name:\s*(.+?)\s*$", block)
    desc = re.search(r"(?m)^description:\s*(.+?)\s*$", block)
    if not (name and desc):
        raise SystemExit(f"{skill_md}: missing name/description")
    value = desc.group(1)
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        value = value[1:-1]
    return name.group(1), value


def skills_meta_chars(skills_dir: Path) -> tuple[int, int]:
    count, chars = 0, 0
    for skill_md in sorted(skills_dir.glob("*/SKILL.md")):
        name, desc = frontmatter_meta(skill_md)
        count += 1
        chars += len(f"{name}: {desc}")
    return count, chars


def coding_discipline_payload(repo: Path) -> str:
    plugin = repo / "plugins" / "coding-discipline"
    body = (plugin / "hooks" / "skill-discipline.md").read_text(encoding="utf-8")
    mech = (
        "> On this host, invoke the skill with the **Skill tool**. Reading "
        "`SKILL.md` as an ordinary file does not count as invoking it."
    )
    return f"<EXTREMELY_IMPORTANT>\n{body}\n{mech}\n</EXTREMELY_IMPORTANT>"


def superpowers_payload(repo: Path) -> str:
    body = (repo / "skills" / "using-superpowers" / "SKILL.md").read_text(encoding="utf-8")
    return (
        "<EXTREMELY_IMPORTANT>\nYou have superpowers.\n\n"
        "**Below is the full content of your 'superpowers:using-superpowers' "
        "skill - your introduction to using skills. For all other skills, "
        f"use the 'Skill' tool:**\n\n{body}\n</EXTREMELY_IMPORTANT>"
    )


def report(label: str, payload: str, skills_dir: Path) -> int:
    count, meta = skills_meta_chars(skills_dir)
    total = len(payload) + meta
    print(f"{label}")
    print(f"  SessionStart hook payload : {len(payload):>6,} chars")
    print(f"  skill metadata ({count:>2} skills): {meta:>6,} chars")
    print(f"  fixed context total       : {total:>6,} chars  (~{round(total / TOKEN_CHARS):,} tokens)")
    return total


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    cd_repo, sp_repo = Path(sys.argv[1]), Path(sys.argv[2])

    cd_total = report(
        "coding-discipline",
        coding_discipline_payload(cd_repo),
        cd_repo / "plugins" / "coding-discipline" / "skills",
    )
    print()
    sp_total = report("superpowers", superpowers_payload(sp_repo), sp_repo / "skills")
    print()
    print(f"ratio: {sp_total / cd_total:.2f}x")


if __name__ == "__main__":
    main()
