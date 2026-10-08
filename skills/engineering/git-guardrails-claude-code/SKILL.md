---
name: git-guardrails-claude-code
description: Set up a Claude Code hook that stops git commands whose damage can't be undone (clean, reset --hard, discarding uncommitted changes, dropping stashes, force push) and asks the user to approve each one. Use when the user wants to protect untracked results, checkpoints or data from an autonomous agent, or add git safety hooks to Claude Code.
---

# Setup Git Guardrails

Sets up a PreToolUse hook that checks every Bash command before Claude Code runs it. A git command whose damage cannot be undone is not run silently: Claude Code shows the user a permission prompt with the reason, and the command runs only if they approve. Everything else passes through untouched. The hook is deterministic, so it holds whatever model is driving the session.

Research repos make this matter more than usual: results, checkpoints, caches and local data often sit untracked next to the code, and one `git clean -xfd` or `git checkout -- .` removes them with nothing to recover from.

## What needs approval

Only operations with no undo:

- `git clean` in any form except a dry run (`-n`, `--dry-run`): untracked files are gone.
- `git reset --hard`, `git checkout .`, `git checkout [<ref>] -- <paths>`, `git restore <paths>`, `git restore --worktree`: uncommitted changes are gone. (`git restore --staged` alone only unstages, and passes.)
- `git stash drop` / `git stash clear`: stashed changes are gone.
- Force push (`--force`, `--force-with-lease`, `-f`, `+<refspec>`): remote history is overwritten for everyone.

Deliberately not gated, because they can be undone: ordinary `git push` (revert), `git branch -D` (the commits stay in the reflog), `git reset` without `--hard`. They still go through Claude Code's normal permission rules. Global options such as `git -C <dir>` are recognised.

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

Ask if the user wants to change what needs approval: add a rule (for example, approval for every push to `main`) or turn an `ask` into a hard block by printing `"permissionDecision": "deny"` instead. Edit the copied script accordingly.

### 5. Verify

Run one gated and one ungated case through the installed script:

```bash
echo '{"tool_input":{"command":"git clean -xfd"}}' | <path-to-script>; echo "exit $?"
echo '{"tool_input":{"command":"git status"}}' | <path-to-script>; echo "exit $?"
```

The first must print JSON with `"permissionDecision": "ask"` and exit 0; the second must print nothing and exit 0. If either is wrong, fix before finishing.

Then tell the user to try it once in a real session in the permission mode they normally use (ask Claude to run `git clean -n` and then `git clean -fd` in a scratch repo) and confirm the second one prompts them.
