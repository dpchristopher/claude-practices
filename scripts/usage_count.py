#!/usr/bin/env python3
"""usage_count.py — count real Skill invocations and Agent dispatches from the transcript corpus.

WHY THIS EXISTS (2026-09-13)
The first version of usage-report.sh grepped raw transcripts for the string "subagent_type".
That had one real defect: **an Agent call with no `subagent_type` field is invisible to it.**
Twenty of 480 dispatches in the corpus carry no such field (they default to general-purpose),
so the grep under-counted general-purpose and could not see those calls at all.

A correction recorded because it was nearly shipped as fact: while building this, a sample
session showed 4 raw "subagent_type" mentions for 1 dispatch, and the conclusion drawn was that
grep over-counted ~4x. **That was generalised from one session and is false.** Measured across
the whole corpus, raw mentions vs distinct Agent calls is 475 vs 480 - a ratio of 0.99x. The
sample was atypical. The docstring briefly claimed "4x" before the corpus-wide check refuted it.

This parses each line as JSON, finds assistant `tool_use` blocks, and dedupes by tool-use id.
Dedup was verified safe: 0 of 480 Agent call ids appear in more than one transcript, so the
main-session vs subagent attribution below cannot be scrambled by file order.

Same lesson as the XML-comment hook: parse the structure, do not pattern-match the text.

It also separates dispatches made by the MAIN session from those made by SUBAGENTS (nested
dispatch). Both are real, but they answer different questions: main-session counts show what
you and Claude chose; nested counts show what agents chose on their own.
"""
import json
import sys
from collections import Counter
from pathlib import Path

CORPUS = Path.home() / ".claude" / "projects"


def is_sidechain(path: Path) -> bool:
    try:
        with path.open(encoding="utf-8", errors="replace") as fh:
            first = fh.readline()
        return '"isSidechain":true' in first.replace(" ", "")
    except OSError:
        return False


def tool_uses(path: Path):
    """Yield (tool_use_id, name, input) for every tool_use block in a transcript."""
    try:
        fh = path.open(encoding="utf-8", errors="replace")
    except OSError:
        return
    with fh:
        for line in fh:
            line = line.strip()
            if not line or '"tool_use"' not in line:   # cheap pre-filter; most lines aren't calls
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue
            msg = rec.get("message") if isinstance(rec, dict) else None
            content = msg.get("content") if isinstance(msg, dict) else None
            if not isinstance(content, list):
                continue
            for block in content:
                if isinstance(block, dict) and block.get("type") == "tool_use":
                    yield block.get("id"), block.get("name"), block.get("input") or {}


def main(days: int = 0) -> int:
    import time
    cutoff = time.time() - days * 86400 if days > 0 else 0

    files = [p for p in CORPUS.rglob("*.jsonl") if p.stat().st_mtime >= cutoff]
    main_sessions = [p for p in files if not is_sidechain(p)]

    seen: set[str] = set()
    agents_main, agents_nested, skills = Counter(), Counter(), Counter()
    raw_mentions = 0

    for path in files:
        nested = is_sidechain(path)
        for tid, name, inp in tool_uses(path):
            raw_mentions += 1
            if not tid or tid in seen:
                continue
            seen.add(tid)
            if name == "Agent":
                kind = inp.get("subagent_type") or "general-purpose"
                (agents_nested if nested else agents_main)[kind] += 1
            elif name == "Skill":
                skills[inp.get("skill") or "?"] += 1

    window = f"last {days} days" if days > 0 else "all retained history"
    print(f"Usage - {window}")
    print(f"{len(files)} transcripts: {len(main_sessions)} main sessions, "
          f"{len(files) - len(main_sessions)} subagent runs")
    print(f"{len(seen)} distinct tool calls (deduped by id)\n")

    def table(title, counter):
        total = sum(counter.values())
        print(f"-- {title}: {total} --")
        for k, v in counter.most_common():
            print(f"  {v:5}  {k}")
        print()

    table("Skills invoked", skills)
    table("Agents dispatched by MAIN sessions", agents_main)
    table("Agents dispatched by SUBAGENTS (nested)", agents_nested)
    return 0


if __name__ == "__main__":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except AttributeError:
        pass
    sys.exit(main(int(sys.argv[1]) if len(sys.argv) > 1 else 0))
