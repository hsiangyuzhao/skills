---
name: git-guardrails-claude-code
description: Set up a Claude Code hook that blocks git commands which destroy work (push, reset --hard, clean, discarding uncommitted changes, dropping stashes) before they run. Use when the user wants to protect untracked results, checkpoints or data from an autonomous agent, add git safety hooks, or block git push/reset in Claude Code.
---

# Setup Git Guardrails

Sets up a PreToolUse hook that intercepts dangerous git commands before Claude Code runs them. It is deterministic: it holds whatever model is driving the session.

Research repos make this matter more than usual: results, checkpoints, caches and local data often sit untracked next to the code, and one `git clean -xfd` or `git checkout -- .` from an agent removes them with no undo.

## What gets blocked

- `git push` (all variants)
- `git reset --hard`
- `git clean` in any form except a dry run (`-n`, `--dry-run`)
- `git checkout .` and `git checkout [<ref>] -- <paths>`
- `git restore <paths>` and `git restore --worktree` (`git restore --staged` alone is allowed)
- `git stash drop` / `git stash clear`
- `git branch -D`

Global options such as `git -C <dir>` are recognised. When blocked, Claude sees a message saying the user has prevented it and should ask them to run the command.

This is Claude Code only. Codex and other harnesses have their own approval and sandbox settings; configure those there.

## Steps

### 1. Check prerequisites and ask scope

The script needs `jq`; check with `command -v jq` and tell the user how to install it if missing.

Ask the user: install for **this project only** (`.claude/settings.json`) or **all projects** (`~/.claude/settings.json`)?

### 2. Copy the hook script

The bundled script is at: [scripts/block-dangerous-git.sh](scripts/block-dangerous-git.sh)

Copy it to the target location based on scope:

- **Project**: `.claude/hooks/block-dangerous-git.sh`
- **Global**: `~/.claude/hooks/block-dangerous-git.sh`

Make it executable with `chmod +x`.

### 3. Add hook to settings

Add to the appropriate settings file:

**Project** (`.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

**Global** (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

If the settings file already exists, merge the hook into the existing `hooks.PreToolUse` array. Don't overwrite other settings.

### 4. Ask about customization

Ask if the user wants to add or remove any rules (for example, allowing `git push` to a personal experiment branch). Edit the copied script accordingly.

### 5. Verify

Run one blocked and one allowed case through the installed script:

```bash
echo '{"tool_input":{"command":"git clean -xfd"}}' | <path-to-script>; echo "exit $?"
echo '{"tool_input":{"command":"git status"}}' | <path-to-script>; echo "exit $?"
```

The first must exit 2 with a BLOCKED message on stderr; the second must exit 0. If either is wrong, fix before finishing.
