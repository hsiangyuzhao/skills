# Skills for Research Code

Agent skills for people whose code exists to answer research questions: medical image analysis, multimodal and audio language models, clinical and mental-health ML. They work with Claude Code, Codex and any harness that reads Agent Skills.

This is a trimmed and adapted fork of [mattpocock/skills](https://github.com/mattpocock/skills) (based on upstream v1.3.1, commit `f3fc563`). The upstream set is built for product engineering: specs, tickets, issue-tracker workflows, PRs. Research code has a different shape, so this fork keeps a smaller set and bends it towards research.

## What this fork keeps, and why

Current frontier models already do most of what a generic "how to code well" prompt says. A skill still earns its place when it supplies one of three things a model cannot bring on its own:

1. **Project state that outlives a session**: the project's vocabulary and the decisions behind it (`GLOSSARY.md`, ADRs).
2. **Deterministic guardrails**: hooks and scripts that hold whatever model is driving.
3. **A deliberate departure from the default**: agents are trained to start work quickly; some work (an experiment design, a hard bug) goes better when they are made to ask first or to build a signal first.

Kept on that basis, and changed for research:

| Change | Skill |
|---|---|
| Phase 1 rebuilt around silent ML failures: tiny-batch overfit, determinism check, reference diff, invariants, visual dump plus a number. Trigger narrowed to hard bugs. A new close-out step names results that need re-running. | `diagnosing-bugs` |
| Replaces upstream `tdd`. No full red-green-refactor; tests only where a silent error changes results (metrics, coordinate transforms, splits, preprocessing, losses), with independent oracles and Python examples. | `correctness-tests` |
| Now user-invoked. The Spec axis accepts a paper's method section or an experiment plan and checks splits, preprocessing, settings and metric computation against it. No issue tracker required. | `code-review` |
| Patterns hardened (`git clean -xfd`, `git checkout -- <file>`, `git stash drop`, `git -C <dir> ...`) because research repos keep untracked results and checkpoints next to the code. | `git-guardrails-claude-code` |
| Evaluation-protocol decisions called out as prime ADR material. | `domain-modeling` |
| Written for a reader in another harness or on another model. | `handoff` |
| Writes for a recipient in another field (a clinician answering an ML question). | `to-questionnaire` |
| Primary sources for research topics are the papers and official code. | `teach` |
| LaTeX paper sections with `\cite{}` keys carried through. | `writing-shape` |
| Python examples. | `codebase-design` |

Every skill that writes a file the agent may share (glossaries, ADRs, handoffs, questionnaires, test fixtures, debug output) also says to keep governed data out: participant records, identifiers and raw clinical values stay where the data use agreement keeps them.

Dropped: the spec and ticket pipeline (`to-spec`, `to-tickets`, `implement`, `implement-spec`, `triage`, `wayfinder`, `setup-matt-pocock-skills`, `ask-matt`), `pr`, `prototype`, `research`, `retro`, `wizard`, `wait-what`, `writing-for-agents`, the TypeScript-specific `misc/` skills and the remaining `in-progress/` skills. Upstream's docs pages, changesets and issue-management workflows went with them.

## Installation

No setup step is needed: none of these skills depends on an issue tracker.

**Link the repo into every harness (recommended).** Clone it, then run:

```bash
scripts/link-skills.sh
```

It symlinks each skill into `~/.claude/skills` (Claude Code) and `~/.agents/skills` (Codex and other Agent Skills harnesses), so one `git pull` updates every CLI you use.

**Copy selected skills into a project** with [skills.sh](https://skills.sh):

```bash
npx skills@latest add hsiangyuzhao/skills
```

**Claude Code plugin** (installs the whole set, read-only):

```bash
claude plugin marketplace add hsiangyuzhao/skills
claude plugin install research-skills@hsiangyuzhao
```

## How they fit together

- **Before running anything**: `/grill-me` to stress-test an experiment design, a paper's framing or a rebuttal. In a long-lived repo, `/grill-with-docs` runs the same interview and records terms and decisions as it goes.
- **When the answer sits with someone else**: `/to-questionnaire` writes a clinical collaborator a questionnaire aimed at exactly what you need from them.
- **While building infrastructure code** (frameworks, data pipelines, evaluation harnesses): `codebase-design` for interface shape, `correctness-tests` at the seams that can silently corrupt results, `/improve-codebase-architecture` now and then.
- **When something is wrong but nothing errors**: `diagnosing-bugs`.
- **Before releasing code or submitting**: `/code-review` against the paper's method section.
- **Across sessions and tools**: `/handoff` when moving work to another harness or model; `git-guardrails-claude-code` once per machine.
- **Learning and writing**: `/teach` for a new field over several sessions; `/writing-fragments` then `/writing-shape` to turn notes into a paper section or an essay, paragraph by paragraph.

## Reference

**User-invoked** skills run only when you type them (e.g. `/grill-me`). **Model-invoked** skills can also be picked up by the agent when the task fits. Skills marked _core_ are the ones worth reaching for routinely; the rest are for when the situation calls for them.

### Engineering

**User-invoked**

- **[code-review](./skills/engineering/code-review/SKILL.md)**: Two-axis review of the diff since a fixed point, run as parallel sub-agents: **Standards** (repo conventions plus a smell baseline) and **Spec** (does the code do what the issue, plan or paper's method section says, including splits, preprocessing and metrics?).
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** _(core)_: A grilling session that also builds the project's domain model, updating `GLOSSARY.md` and ADRs as terms and decisions settle.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)**: Survey a long-lived codebase for deepening opportunities, present them as a visual HTML report, then grill through the one you pick.

**Model-invoked**

- **[diagnosing-bugs](./skills/engineering/diagnosing-bugs/SKILL.md)** _(core)_: Diagnosis loop for hard and silent bugs in research code: build a fast signal that goes red on this bug, minimise, hypothesise, instrument, fix with a regression test, and name any results that need re-running.
- **[domain-modeling](./skills/engineering/domain-modeling/SKILL.md)** _(core)_: Build and sharpen the project's vocabulary and record hard-to-reverse decisions (evaluation protocol above all) in `GLOSSARY.md` and ADRs.
- **[git-guardrails-claude-code](./skills/engineering/git-guardrails-claude-code/SKILL.md)** _(core)_: Install a Claude Code hook that blocks git commands which destroy work: push, hard reset, clean, discarding uncommitted changes, dropping stashes.
- **[correctness-tests](./skills/engineering/correctness-tests/SKILL.md)**: The few tests research code needs, at seams where a silent error changes results, each checked against an independent oracle.
- **[codebase-design](./skills/engineering/codebase-design/SKILL.md)**: Shared vocabulary for designing deep modules: a lot of behaviour behind a small interface, at a clean seam, testable through that interface.

### Productivity

**User-invoked**

- **[grill-me](./skills/productivity/grill-me/SKILL.md)** _(core)_: Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved. Saves nothing; use `grill-with-docs` inside a repo.
- **[handoff](./skills/productivity/handoff/SKILL.md)** _(core)_: Compact the current conversation into a document another agent, in any harness or on any model, can pick up.
- **[to-questionnaire](./skills/productivity/to-questionnaire/SKILL.md)** _(core)_: Turn a decision you can't make alone into a questionnaire for the one person who can, written in their vocabulary.
- **[teach](./skills/productivity/teach/SKILL.md)**: Learn a new field over multiple sessions in a stateful workspace of lessons, reference sheets and learning records, grounded in primary sources.

**Model-invoked**

- **[grilling](./skills/productivity/grilling/SKILL.md)**: The interview primitive behind `grill-me`, `grill-with-docs` and `improve-codebase-architecture`: rounds of questions with a recommended answer each; facts are the agent's job, decisions are yours.

### Writing

**User-invoked**

- **[writing-fragments](./skills/writing/writing-fragments/SKILL.md)**: An interview that mines you for raw fragments of writing and appends them to one file, with no structure imposed yet.
- **[writing-shape](./skills/writing/writing-shape/SKILL.md)**: Shape a file of raw material into an article or paper section, paragraph by paragraph, arguing each format choice.

## License

MIT, as upstream. Original work copyright Matt Pocock; see [LICENSE](./LICENSE).
