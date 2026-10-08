# Productivity

Workflow tools that are not about code.

## User-invoked

Reachable only when you type them (Claude Code: `disable-model-invocation: true`; Codex: `policy.allow_implicit_invocation: false` in `agents/openai.yaml`).

- **[grill-me](./grill-me/SKILL.md)**: Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[handoff](./handoff/SKILL.md)**: Compact the current conversation into a document another agent, in any harness or on any model, can pick up.
- **[to-questionnaire](./to-questionnaire/SKILL.md)**: Turn a decision you can't make alone into a questionnaire for the one person who can, written in their vocabulary.
- **[teach](./teach/SKILL.md)**: Learn a new field over multiple sessions, using the current directory as a stateful teaching workspace.

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[grilling](./grilling/SKILL.md)**: Interview the user relentlessly about a plan, decision, or idea until every branch of the decision tree is resolved.
