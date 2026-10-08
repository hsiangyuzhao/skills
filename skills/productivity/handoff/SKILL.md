---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. The next agent may run in a different harness or on a different model (Claude Code, Codex, another backend), so write it for a reader that has none of this session's tools, skills or memory: name commands, paths and decisions explicitly. Save to the temporary directory of the user's OS (`$TMPDIR`, else `/tmp`; `%TEMP%` on Windows) - not the current workspace.

Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information. Governed research data (participant records, identifiers, raw clinical values) never goes in: point to where the data lives and how to access it, not to its contents.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
