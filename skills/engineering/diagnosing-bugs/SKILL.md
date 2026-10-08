---
name: diagnosing-bugs
description: Diagnosis loop for hard bugs in research code, where failures are often silent. Use when the user says "diagnose" or "debug this"; when a model trains but won't converge, hits NaNs, or scores suspiciously well; when outputs are misaligned or a run won't reproduce; when something got slow; or when a first fix attempt already failed. Skip it when the traceback already names the cause.
---

# Diagnosing Bugs

A discipline for hard bugs. Scale it to the bug: when the traceback already names the cause, fix it and move on, no loop needed. Once a bug earns this skill, skip a phase only with a stated reason.

Research code fails quietly. A broken pipeline still trains, still writes a checkpoint, still prints a number. That is why the loop below matters more here than in application code: without a signal that goes **red** on this bug, a silent failure looks exactly like a disappointing result.

When exploring the codebase, read `GLOSSARY.md` (if it exists) for the project's terms, and check ADRs in the area you're touching.

## Redact and protect data

This skill has you show commands, outputs and captured artifacts.

- **Secrets**: write `<REDACTED>` in their place. Build loops against env vars, so credentials stay in the environment rather than in what you show.
- **Governed data**: datasets under a data use agreement (UK Biobank, clinical cohorts, anything with participant records) stay where they are. Show shapes, dtypes, value ranges and summary statistics, never rows, identifiers or raw clinical values. Fixtures and regression tests use synthetic data shaped like the real thing.

If what you can show is not enough to diagnose the bug, say so and ask the user.

## Phase 1: Build a feedback loop

**This is the skill.** Everything else is mechanical. If you have a **tight** pass/fail signal for the bug (one that goes **red** on _this_ bug), you will find the cause; bisection, hypothesis-testing, and instrumentation all just consume it. If you don't have one, no amount of staring at code will save you.

Spend disproportionate effort here. **Be aggressive. Be creative. Refuse to give up.**

### Ways to construct one, in roughly this order

1. **Failing test** at whatever seam reaches the bug (a pytest case calling the function, the dataset, or the training step).
2. **Tiny-batch overfit.** Run the real pipeline on 1 to 8 samples for a few hundred steps. A correct model, loss, optimiser and label path drive training loss towards zero; if it plateaus, the bug is there and not in data scale.
3. **Determinism check.** Two runs, same seed, same data order; diff losses or outputs step by step. The first divergence localises the nondeterminism (dataloader workers, augmentation RNG, cuDNN algorithms, distributed sampler).
4. **Reference diff.** Push the same input through your code and a trusted reference (the official implementation, a library metric, the last good commit, CPU vs GPU, fp32 vs bf16) and assert agreement within a stated tolerance.
5. **Invariant assertions.** Check what must hold whatever the model does: a transform followed by its inverse returns the input; coordinates land inside image bounds; mask area survives resampling within tolerance; probabilities sum to one; no subject appears in both train and test.
6. **Visual dump plus a number.** Write overlays to files for the human (mask on image, predicted vs ground-truth geometry, spectrogram with labels), and pair each with a number the loop can assert on: IoU against a hand-checked case, centroid offset in pixels, onset error in milliseconds.
7. **Captured-batch replay.** Save the offending batch, checkpoint and resolved config to disk (tensors, not identifiable records) and replay the failing step on them in isolation.
8. **CLI or script with a fixture input**, diffing output against a known-good snapshot.
9. **Bisection harness.** If the bug appeared between two known states (commit, config, data version, dependency version), automate "set up state X, check, repeat" and `git bisect run` it.
10. **Property or fuzz loop.** If the bug is "sometimes wrong", run many random inputs and look for the failure mode.
11. **HITL bash script.** Last resort. If a human must look or click, drive _them_ with `scripts/hitl-loop.template.sh` so the loop is still structured. Captured output feeds back to you.

Build the right feedback loop, and the bug is 90% fixed.

### Tighten the loop

Treat the loop as a product. A 20-minute training run is not a loop. Once you have _a_ loop, **tighten** it:

- **Faster**: shrink the model (fewer layers, smaller input size), subset the data, skip evaluation and logging, run on CPU if the bug reproduces there.
- **Sharper**: assert on the specific symptom, not "didn't crash". For a silent bug the symptom is a number, so write the threshold down.
- **More deterministic**: seed Python, NumPy and the framework, turn on deterministic algorithms, set dataloader workers to zero, pin library versions.

A slow, flaky loop is barely better than no loop; a few-second deterministic one is tight, a debugging superpower.

### Non-deterministic bugs

The goal is not a clean repro but a **higher reproduction rate**. Loop the trigger many times, parallelise, add stress, vary seeds deliberately. A 50%-flake bug is debuggable; 1% is not, so keep raising the rate until it's debuggable.

### When you genuinely cannot build a loop

Stop and say so explicitly. List what you tried. Ask the user for: (a) access to whatever environment reproduces it (the cluster, the full dataset, the specific GPU), (b) a captured artifact that carries no participant data (logs, a saved batch of tensors, a resolved config, a profiler trace), or (c) permission to add temporary instrumentation to a real run. Do **not** proceed to hypothesise without a loop.

### Completion criterion: a tight loop that goes red

Phase 1 is done when the loop is **tight** and **red-capable**: you can name **one command** (a script path, a test invocation) that you have **already run at least once** (show the invocation and its redacted output), and that is:

- [ ] **Red-capable**: it drives the actual bug code path and asserts the **user's exact symptom**, so it can go red on this bug and green once fixed. Not "runs without erroring"; it must be able to _catch this specific bug_.
- [ ] **Deterministic**: same verdict every run (flaky bugs: a pinned, high reproduction rate, per above).
- [ ] **Fast**: seconds, not minutes.
- [ ] **Agent-runnable**: you can run it unattended; a human in the loop only via `scripts/hitl-loop.template.sh`.

If you catch yourself reading code to build a theory before this command exists, **stop: jumping straight to a hypothesis is the exact failure this skill prevents.** No red-capable command, no Phase 2.

## Phase 2: Reproduce + minimise

Run the loop. Watch it go red as the bug appears.

Confirm:

- [ ] The loop produces the failure mode the **user** described, not a different failure that happens to be nearby. Wrong bug = wrong fix.
- [ ] The failure is reproducible across multiple runs (or, for non-deterministic bugs, at a high enough rate to debug against).
- [ ] You have captured the exact symptom (error, wrong number, misalignment, timing) so later phases can verify the fix addresses it.

### Minimise

Once it's red, shrink the repro to the **smallest scenario that still goes red**. Cut samples, model size, config overrides, augmentations, callers and steps **one at a time**, re-running the loop after each cut, and keep only what's load-bearing.

Why bother: a minimal repro shrinks the hypothesis space in Phase 3 and becomes the clean regression test in Phase 5.

Done when **every remaining element is load-bearing**: removing any one of them makes the loop go green.

## Phase 3: Hypothesise

Generate **3 to 5 ranked hypotheses** before testing any of them. Single-hypothesis generation anchors on the first plausible idea. In ML code, rank data-path suspects (labels, splits, preprocessing, coordinate frames, normalisation) above model suspects unless the loop says otherwise: they are the more common cause and cheaper to test.

Each hypothesis must be **falsifiable**: state the prediction it makes.

> Format: "If <X> is the cause, then <changing Y> will make the bug disappear / <changing Z> will make it worse."

If you cannot state the prediction, the hypothesis is a vibe: discard or sharpen it.

**Show the ranked list to the user before testing.** They often hold domain knowledge that re-ranks instantly ("that cohort was relabelled last month"). Don't block on it; proceed with your ranking if the user is away.

## Phase 4: Instrument

Each probe must map to a specific prediction from Phase 3. **Change one variable at a time.**

Tool preference:

1. **Debugger or REPL inspection** where the environment supports it. One breakpoint beats ten logs.
2. **Targeted logs** at the boundaries that distinguish hypotheses. For tensors, log summaries (shape, dtype, device, min, max, mean, NaN count), never whole tensors.
3. Never "log everything and grep".

**Tag every debug log** with a unique prefix, e.g. `[DEBUG-a4f2]`. Cleanup at the end becomes a single grep.

**Perf branch.** For slowdowns, logs are usually wrong. Measure first: time each stage separately (data loading, transfer, forward, backward, evaluation), check device utilisation, then profile the stage that dominates. Only then change code, and re-measure against the baseline.

## Phase 5: Fix + regression test

Write the regression test **before the fix**, but only if there is a **correct seam** for it: one where the test exercises the real bug pattern as it occurs in the pipeline. A seam too shallow to replicate the chain that triggered the bug gives false confidence. **If no correct seam exists, that itself is the finding**: note it.

If a correct seam exists:

1. Turn the minimised repro into a failing test at that seam, on synthetic data. Call the Skill tool with "correctness-tests" for how to pick an independent expected value.
2. Watch it fail. If you forced the red by mutating code or a fixture, `diff` against a pristine copy to prove the mutation landed before you trust it.
3. Apply the fix.
4. Watch it pass.
5. Re-run the Phase 1 feedback loop against the original (un-minimised) scenario.

## Phase 6: Cleanup

Required before declaring done:

- [ ] Original repro no longer reproduces (re-run the Phase 1 loop)
- [ ] Regression test passes (or absence of a seam is documented)
- [ ] All `[DEBUG-...]` instrumentation removed (`grep` the prefix)
- [ ] Throwaway harnesses deleted, or moved to a clearly marked debug location
- [ ] The hypothesis that turned out correct is stated in the commit message, so the next debugger learns
- [ ] **Affected results named**: if the bug could have touched anything reported or about to be reported (metrics, tables, figures, checkpoints others use), list which runs or experiments need re-running. A fixed bug with stale numbers in a paper is not fixed.
