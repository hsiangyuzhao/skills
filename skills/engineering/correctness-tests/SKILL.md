---
name: correctness-tests
description: Write the few tests research code needs, at the seams where a silent error would corrupt results (metrics, coordinate and geometry transforms, data splits, preprocessing, losses). Use when the user asks for tests, when writing or changing one of those seams, or when turning a fixed bug into a regression test.
---

# Correctness Tests

Research code does not need coverage. It needs the handful of tests that stop a wrong number from reaching a paper. Exploratory scripts, plotting code and one-off analyses get none; the seams below get tests every time they change.

When exploring the codebase, read `GLOSSARY.md` (if it exists) so test names match the project's terms, and respect ADRs in the area you're touching.

## Seams: where tests go

A **seam** is the public boundary you test at: the interface where you observe behaviour without reaching inside. Tests live at seams, never against internals.

Spend tests where an error is **silent and changes results**:

- **Metrics and evaluation**: Dice, IoU, AUROC, calibration, your own benchmark scoring.
- **Coordinate, geometry and resolution transforms**: pixel to physical units, pyramid levels, format conversions, crops and their offsets.
- **Data splits and joins**: subject-level leakage, label alignment after a merge, cohort filters.
- **Preprocessing and its inverse**: normalisation, resampling, audio framing, tokenisation.
- **Losses and masking logic**: ignore indices, padding masks, class weighting.

**Agree the seams.** When the user is present, list the proposed seams, each with one line on what it catches and what it misses, and confirm before writing tests. When working unattended, choose them yourself and state them at the top of your report so they can be checked later.

When the shape of an interface is itself in question (where the seam belongs, what it should expose), call the Skill tool with "codebase-design" for the vocabulary.

## Independent oracles

The expected value must come from somewhere other than the code under test:

- **Hand-worked literal**: an example small enough to verify on paper (a 3x3 mask, four samples, one window of audio).
- **Reference implementation**: a library metric or the official code, compared within an explicit tolerance.
- **Invariant**: a property that holds whatever the input (round trip returns the input, output within bounds, symmetric where it should be, invariant to sample order).
- **Published value**: a number the reference reports on its own example, reproduced.

Every float comparison names its tolerance (`atol`, `rtol`) and the reason for it.

## Anti-patterns

- **Tautological**: the assertion recomputes the expected value the way the code does, so it passes by construction and can never disagree with the code.
- **Implementation-coupled**: mocks your own modules, tests private helpers, or verifies through a side channel. The tell: it breaks under a refactor that changed no behaviour.
- **Weakened to pass**: changing the expected value or loosening a tolerance until the test goes green. A red test means the code is suspect until shown otherwise; changing an expectation needs a stated reason the user can check.
- **Real data in tests**: fixtures are synthetic. Participant-level or otherwise governed data never goes into a test file, a fixture or a snapshot.

## Mocking

Mock only true boundaries: network and external APIs, the clock, and heavy pretrained weights (swap in a tiny randomly initialised model with the same interface). Seed randomness rather than mocking it. Never mock your own modules.

## Rules of the loop

- **See it go red.** A regression test must fail before the fix. A test for new code must catch a deliberate break (flip a sign, shift a coordinate by one, swap two labels); confirm it goes red, revert, and `diff` against a pristine copy to prove the revert landed.
- **Fast and on CPU.** The whole set runs in seconds, so it gets run.
- **One seam at a time.** One seam, one test, then the next, rather than writing every test up front.

See [tests.md](tests.md) for examples.
