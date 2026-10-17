#!/usr/bin/env bash
# PostToolUse hook for Edit and Write. A change to a screen is the one kind of
# change a diff cannot verify: a centred card, an overflowing value and two
# identical buttons all look right in the source. This says so once a session,
# the first time a screen file is changed.
# Every failure exits 0 with no output, so a broken hook never changes a result.

set -uo pipefail

[[ "${CLAUDE_INSPECT:-on}" == "off" ]] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"
case "$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null)" in
  Edit|Write|NotebookEdit) ;;
  *) exit 0 ;;
esac

path="$(jq -r '.tool_input.file_path // empty' <<<"$input" 2>/dev/null)"
case "$path" in
  *.html|*.htm|*.css|*.scss|*.tsx|*.jsx|*.vue|*.svelte|*.astro) ;;
  *) exit 0 ;;
esac
# A test or a story is not a screen.
case "$path" in *.test.*|*.spec.*|*.stories.*) exit 0 ;; esac

sid="$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)"
case "$sid" in */*|..*|"") exit 0 ;; esac
state="${CLAUDE_INSPECT_HOME:-$HOME/.local/state/claude-system/inspect}"
# The sweep below removes directories, so the root must stay inside the state
# tree. Anything else, and the hook does nothing rather than delete elsewhere.
case "$state" in
  "$HOME/.local/state/claude-system/"*|"${TMPDIR:-/tmp}"*|/tmp/*|/private/var/folders/*) ;;
  *) exit 0 ;;
esac
umask 077
mkdir -p "$state" 2>/dev/null || exit 0
mkdir -p "$state/$sid" 2>/dev/null || exit 0
key="$(printf '%s' "$path" | shasum -a 256 2>/dev/null | cut -c1-16)"
[[ -n "$key" ]] || exit 0
mkdir "$state/$sid/$key" 2>/dev/null || exit 0   # this file was already named
spoken="$(find "$state/$sid" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
(( spoken <= ${CLAUDE_INSPECT_MAX:-3} )) || exit 0

msg="You changed a file that may render a screen. If it does, look at the rendered image before you describe it. Invoke the inspect skill, render at 1440 and at 375, and open the images with Read. Report against its checks by name. Rendering is not the check, and reading the source is not looking. If you cannot render it, say so rather than describing the source."
jq -cn --arg m "$msg" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $m}}'

# Every directory this hook makes is an empty marker, so the sweep uses -delete,
# which refuses a directory with anything in it. A mis-set root can then never
# remove a file or a folder that holds one.
find "$state" -mindepth 2 -maxdepth 2 -type d -mtime +7 -delete 2>/dev/null
find "$state" -mindepth 1 -maxdepth 1 -type d -empty -mtime +7 -delete 2>/dev/null
exit 0
