# Engineering

Skills for code: debugging, tests, design and review, adapted for research code.

## User-invoked

Reachable only when you type them (Claude Code: `disable-model-invocation: true`; Codex: `policy.allow_implicit_invocation: false` in `agents/openai.yaml`).

- **[code-review](./code-review/SKILL.md)**: Two-axis review of the diff since a fixed point: **Standards** (repo conventions plus a smell baseline) and **Spec** (does the code do what the issue, plan or paper's method section says?), run as parallel sub-agents.
- **[grill-with-docs](./grill-with-docs/SKILL.md)**: Grilling session that also builds the project's domain model, updating `GLOSSARY.md` and ADRs inline.
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)**: Survey a long-lived codebase for deepening opportunities, present them as a visual HTML report, then grill through the one you pick.

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[diagnosing-bugs](./diagnosing-bugs/SKILL.md)**: Diagnosis loop for hard and silent bugs in research code: a fast signal that goes red on this bug, then minimise, hypothesise, instrument, fix, and name results that need re-running.
- **[domain-modeling](./domain-modeling/SKILL.md)**: Build and sharpen the project's vocabulary and record hard-to-reverse decisions in `GLOSSARY.md` and ADRs.
- **[git-guardrails-claude-code](./git-guardrails-claude-code/SKILL.md)**: Install a Claude Code hook that asks for your approval before any git command with no undo.
- **[correctness-tests](./correctness-tests/SKILL.md)**: The few tests research code needs, at seams where a silent error changes results, each checked against an independent oracle.
- **[codebase-design](./codebase-design/SKILL.md)**: Shared vocabulary for designing deep modules: small interfaces, clean seams, testable through the interface.
