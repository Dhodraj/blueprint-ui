#!/usr/bin/env bash
# Tests for the screen-edit hook. No network, no writes outside a temp folder.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
hook="$here/../hooks/inspect-nudge.sh"
pass=0; fail=0
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
export CLAUDE_INSPECT_HOME="$tmp/state"

ok()  { if [[ "$2" == "$3" ]]; then pass=$((pass+1)); else fail=$((fail+1)); printf 'FAIL %s\n  want: %s\n  got:  %s\n' "$1" "$3" "${2:0:120}"; fi; }
has() { if grep -q "$3" <<<"$2"; then pass=$((pass+1)); else fail=$((fail+1)); printf 'FAIL %s (missing %s)\n' "$1" "$3"; fi; }
fires() { [[ -n "$1" ]] && echo yes || echo no; }

call() { # <tool> <path> [session]
  jq -cn --arg t "$1" --arg p "$2" --arg s "${3:-sess1}" \
    '{session_id:$s, hook_event_name:"PostToolUse", tool_name:$t,
      tool_input:{file_path:$p}, tool_response:{filePath:$p, type:"update"}}' | bash "$hook"
}

out="$(call Edit /work/mock/screens/sign-in.html)"
has "an html edit is noticed" "$out" "look at the rendered image"
has "it names the event" "$out" "PostToolUse"
has "it names both widths" "$out" "1440"
has "it points at the skill" "$out" "inspect skill"
ok  "it never decides a tool call" "$(grep -c 'permissionDecision' <<<"$out" || true)" "0"

ok "the same file twice speaks once" "$(fires "$(call Edit /work/mock/screens/sign-in.html sess1)")" "no"
ok "a new session speaks again" "$(fires "$(call Edit /work/a.css sess2)")" "yes"

for ext in tsx jsx vue svelte scss astro htm; do
  ok "a .$ext edit is noticed" "$(fires "$(call Write /work/x.$ext "s-$ext")")" "yes"
done
for p in /work/main.py /work/README.md /work/data.json /work/x.test.tsx /work/y.stories.jsx /work/z.spec.css; do
  ok "$(basename "$p") is ignored" "$(fires "$(call Edit "$p" "p$RANDOM")")" "no"
done

ok "a Bash call is ignored" "$(fires "$(call Bash /work/a.html b1)")" "no"
ok "a Read is ignored" "$(fires "$(call Read /work/a.html r1)")" "no"
ok "the off switch silences it" "$(CLAUDE_INSPECT=off call Edit /work/a.html off1)" ""
ok "a session id with a path writes nothing" "$(call Edit /work/a.html ../../evil)" ""
ok "malformed input exits 0" "$(printf 'not json' | bash "$hook"; echo $?)" "0"
ok "the state folder is private" "$(stat -f '%Lp' "$CLAUDE_INSPECT_HOME")" "700"

# parallel edits still speak once
for i in $(seq 1 10); do call Edit /work/p.html par1 & done >"$tmp/par.out"; wait
ok "ten parallel edits speak once" "$(grep -c 'rendered image' "$tmp/par.out" || true)" "1"

# the reviewer's case: the first match of a session is usually not a screen
ok "a later screen edit still speaks" "$(call Edit /work/src/lib/useAuth.tsx later >/dev/null; fires "$(call Edit /work/src/screens/SignIn.tsx later)")" "yes"
ok "a third file still speaks" "$(fires "$(call Edit /work/src/screens/Overview.tsx later)")" "yes"
ok "a fourth file is silent" "$(fires "$(call Edit /work/src/screens/Audit.tsx later)")" "no"
ok "the cap is configurable" "$(CLAUDE_INSPECT_MAX=5 fires "$(CLAUDE_INSPECT_MAX=5 call Edit /work/src/screens/Four.tsx later)")" "yes"

# the sweep can never be pointed outside the state tree
guard="$tmp/elsewhere"; mkdir -p "$guard/victim"; printf 'keep me\n' > "$guard/victim/keep.txt"
touch -t 202601010000 "$guard/victim/keep.txt" "$guard/victim"
CLAUDE_INSPECT_HOME="$guard" call Edit /work/a.html g1 >/dev/null
ok "the sweep never removes a folder with anything in it" "$(ls "$guard" | grep -c victim || true)" "1"
ok "the file inside it survives" "$(cat "$guard/victim/keep.txt")" "keep me"
ok "a root outside the state tree and outside tmp is refused" "$(CLAUDE_INSPECT_HOME=/etc call Edit /work/a.html g2)" ""

printf '%s passed, %s failed\n' "$pass" "$fail"
(( fail == 0 ))
