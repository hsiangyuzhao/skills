#!/bin/bash
# PreToolUse hook for Claude Code: git commands whose damage cannot be undone
# are escalated to the user for approval instead of running silently.
# Reads the hook payload on stdin; prints a permission decision on stdout.
# Requires jq.

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

S='[[:space:]]'
# "git", optionally followed by global options like -C <dir> or -c k=v
GIT="(^|[^[:alnum:]_-])git($S+-[Cc]$S+[^[:space:]]+)*$S+"

ask() {
  jq -n --arg reason "Irreversible git operation ($1): $2 Approve only if that is intended." '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

has() { printf '%s' "$COMMAND" | grep -qE -- "$1"; }

# Deleting untracked files (results, checkpoints, data caches). Dry runs are fine.
if has "${GIT}clean"; then
  has "${GIT}clean.*($S-[[:alpha:]]*n|--dry-run)" ||
    ask "git clean" "untracked files are deleted and git has no copy of them."
fi

# Discarding uncommitted changes
has "${GIT}reset$S+.*--hard" &&
  ask "git reset --hard" "uncommitted changes to tracked files are discarded."
has "${GIT}checkout$S+(.*$S)?--($S|$)" &&
  ask "git checkout -- <paths>" "uncommitted changes to those paths are discarded."
has "${GIT}checkout$S+\.($S|$)" &&
  ask "git checkout ." "all uncommitted changes in this directory are discarded."
if has "${GIT}restore"; then
  has "${GIT}restore.*($S--worktree|$S-W)" &&
    ask "git restore --worktree" "uncommitted changes to those paths are discarded."
  has "${GIT}restore.*($S--staged|$S-S)" ||
    ask "git restore <paths>" "uncommitted changes to those paths are discarded."
fi
has "${GIT}stash$S+(drop|clear)" &&
  ask "git stash drop/clear" "the stashed changes are deleted."

# Rewriting published history
has "${GIT}push.*$S(--force|-[[:alpha:]]*f|\+[^[:space:]]+)" &&
  ask "force push" "commits on the remote can be overwritten for everyone."

exit 0
