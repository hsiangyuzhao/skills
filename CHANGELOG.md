# research-skills

## 2.0.0

Forked from [mattpocock/skills](https://github.com/mattpocock/skills) v1.3.1 (commit `f3fc563`). Upstream's history up to that point is in [its changelog](https://github.com/mattpocock/skills/blob/main/CHANGELOG.md).

### Removed

- Spec and ticket pipeline: `to-spec`, `to-tickets`, `implement`, `implement-spec`, `triage`, `wayfinder`, `setup-matt-pocock-skills`, `ask-matt`.
- `pr`, `prototype`, `research`, `retro`, `wizard`, `wait-what`, `writing-for-agents`.
- `misc/`: `migrate-to-shoehorn`, `scaffold-exercises`, `setup-pre-commit` (TypeScript and course-specific).
- `in-progress/`: `chief-of-staff`, `claude-handoff`, `loop-me`, `setup-ts-deep-modules`, `writing-beats`.
- Upstream's docs pages, changesets, issue-management workflows, scope notes and release tooling.

### Changed

- **Buckets**: `engineering/`, `productivity/` and a new `writing/`. `git-guardrails-claude-code` moved from `misc/` to `engineering/`; `writing-fragments` and `writing-shape` moved from `in-progress/` to `writing/`. Every skill ships in the plugin.
- **`diagnosing-bugs`**: description narrowed to hard and silent bugs (skip when the traceback names the cause). Phase 1 rebuilt for research code: tiny-batch overfit, determinism check, reference diff, invariant assertions, visual dump plus a number, captured-batch replay. Data-path suspects ranked first in ML code; tensor summaries instead of tensors in logs; perf branch times each pipeline stage. New close-out item: name results that need re-running. Governed data stays out of everything shown or committed.
- **`correctness-tests`** (replaces `tdd`): tests only at seams where a silent error changes results (metrics, coordinate transforms, splits, preprocessing, losses), checked against independent oracles. Adds the "weakened to pass" anti-pattern and the no-real-data rule. Seams are confirmed with the user when present and stated in the report when unattended. Python examples; `mocking.md` folded in.
- **`code-review`**: now user-invoked. The Spec axis accepts a paper's method section, proposal or experiment plan, and checks splits, preprocessing, settings and metric computation against it. No issue tracker required. Standards axis scoped to persistent code; the smell baseline is named rather than spelled out.
- **`git-guardrails-claude-code`**: blocks every `git clean` except dry runs, `git checkout [<ref>] -- <paths>`, `git restore` of the worktree, and `git stash drop/clear`; recognises `git -C <dir>`. Checks for `jq` and verifies one blocked and one allowed case.
- **`domain-modeling`**: evaluation-protocol decisions called out as prime ADR material; governed data kept out of `GLOSSARY.md` and ADRs.
- **`handoff`**: written for a reader in another harness or on another model; governed data referenced by location only.
- **`to-questionnaire`**: writes in the recipient's vocabulary when they work in another field; asks for criteria, never participant-level data.
- **`teach`**: primary sources for research topics are papers and official code.
- **`grilling`**: description names experiment design, paper framing, proposals and rebuttals.
- **`writing-shape`**: LaTeX paper sections with `\cite{}` keys carried through.
- **`codebase-design`**: Python examples.
