---
name: code-review
description: "Two-axis review of the changes since a fixed point: Standards (repo conventions plus a smell baseline) and Spec (does the code do what the issue, plan, or paper's method section says?), run as parallel sub-agents."
disable-model-invocation: true
---

Two-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement what it was written to do, whether that is an issue, an experiment plan, or the method a paper describes?

Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings. The Spec axis is the one that matters most before releasing research code: it catches the gap between what the paper says was done and what the code does.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside two parallel sub-agents.

### 2. Identify the spec source

Look for what the code was meant to do, in this order:

1. A path or text the user passed as an argument.
2. Issue references in the commit messages (`#123`, `Closes #45`), fetched with the tracker's CLI when one is available.
3. A method description in the repo: a paper draft (LaTeX method or experiments section), a proposal, or an experiment plan under `docs/`, `paper/`, `notes/` or similar, matching the branch or feature.
4. If nothing is found, ask the user where it is. If they say there isn't one, the **Spec** sub-agent skips and reports "no spec available".

### 3. Identify the standards sources

Search the repo for every file that documents how code should be written. When `CODING_STANDARDS.md` or `CONTRIBUTING.md` exists, it must be on the list. Also note the linters and formatters the repo runs, so the review skips whatever they already enforce.

Scope the Standards axis to code that persists (library modules, pipelines, evaluation code). Exploratory scripts and notebooks get the Spec axis only.

On top of whatever the repo documents, the Standards axis carries a **smell baseline**: the code smells from Fowler's _Refactoring_ (ch. 3), notably Mysterious Name, Duplicated Code, Feature Envy, Data Clumps, Primitive Obsession, Repeated Switches, Shotgun Surgery, Divergent Change, Speculative Generality, Message Chains, Middle Man and Refused Bequest. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation.

### 4. Spawn both sub-agents in parallel

Issue both sub-agent calls together, in the foreground, and aggregate the reports they return.

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The list of standards-source files from step 3, the tooling that already enforces rules, the scoping rule, and the smell baseline with its two rules.
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asks for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong; (d) where the spec is a method or experiment description, any mismatch in data splits, preprocessing, model or training settings, or how metrics are computed. Quote the spec line for each finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings, because the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the plan said but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
