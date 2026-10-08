#!/bin/bash
# PreToolUse hook for Claude Code: block git commands that destroy work.
# Reads the hook payload on stdin, exits 2 (blocked) with a message on stderr.
# Requires jq.

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

S='[[:space:]]'
# "git", optionally followed by global options like -C <dir> or -c k=v
GIT="(^|[^[:alnum:]_-])git($S+-[Cc]$S+[^[:space:]]+)*$S+"

block() {
  echo "BLOCKED: '$COMMAND' looks like '$1'. The user has prevented you from doing this; ask them to run it if it is really needed." >&2
  exit 2
}

has() { printf '%s' "$COMMAND" | grep -qE -- "$1"; }

# Publishing and history rewriting
has "${GIT}push" && block "git push"
has "${GIT}reset$S+.*--hard" && block "git reset --hard"
has "${GIT}branch$S+.*-D" && block "git branch -D"

# Deleting untracked files (results, checkpoints, data caches). Dry runs are fine.
if has "${GIT}clean"; then
  has "${GIT}clean.*($S-[[:alpha:]]*n|--dry-run)" || block "git clean"
fi

# Discarding uncommitted changes
has "${GIT}checkout$S+(.*$S)?--($S|$)" && block "git checkout -- <paths>"
has "${GIT}checkout$S+\.($S|$)" && block "git checkout ."
if has "${GIT}restore"; then
  has "${GIT}restore.*($S--worktree|$S-W)" && block "git restore --worktree"
  has "${GIT}restore.*($S--staged|$S-S)" || block "git restore <paths>"
fi
has "${GIT}stash$S+(drop|clear)" && block "git stash drop/clear"

exit 0
