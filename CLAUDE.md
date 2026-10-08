This repo is a research-oriented fork of [mattpocock/skills](https://github.com/mattpocock/skills). Skills live in bucket folders under `skills/`:

- `engineering/`: code work (debugging, tests, design, review)
- `productivity/`: non-code workflow tools
- `writing/`: collaborative writing

Every skill must appear in three places: the top-level `README.md` (Reference section, name linked to its `SKILL.md`), its bucket's `README.md`, and `.claude-plugin/plugin.json`'s `skills` array. Run `claude plugin validate .` after touching either manifest; the one expected warning is that this `CLAUDE.md` is not shipped as plugin context, which is intended.

Bucket `README.md`s and the top-level Reference group entries into **User-invoked** and **Model-invoked**. Every `SKILL.md` is one or the other: user-invoked means `disable-model-invocation: true` in the frontmatter plus `policy.allow_implicit_invocation: false` in `agents/openai.yaml`. See [.agents/invocation.md](./.agents/invocation.md), which also covers how one skill calls another.

Skills that write files an agent may commit or share (glossaries, ADRs, handoffs, questionnaires, test fixtures, debug output) must say that governed research data stays out: participant records, identifiers, raw clinical values. Keep that sentence when editing them, and add it to any new skill that writes such files.

To (re)link every skill into the local harness skill directories (`~/.claude/skills`, `~/.agents/skills`), run `scripts/link-skills.sh`. Each entry is a symlink into this repo, so a `git pull` keeps installed skills current; re-run the script after adding, removing, or renaming a skill.

Record every change to a skill's behaviour in `CHANGELOG.md`.

Pulling from upstream: add it as a remote (`git remote add upstream https://github.com/mattpocock/skills`) and port changes by hand. Most kept skills are modified here and several upstream paths no longer exist, so a plain merge will conflict; read the upstream diff and apply only what still fits.

No em-dashes anywhere in this repo's prose (`SKILL.md` files, `README.md`, `CHANGELOG.md`, code comments). Where a sentence reaches for one, rewrite it with a comma, colon, period, parentheses, or a conjunction, whichever the sentence actually wants; never do a blind character substitution.
