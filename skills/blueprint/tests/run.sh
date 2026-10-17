#!/usr/bin/env bash
# Tests for check-sources.js. No network: the --links path is not exercised.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
check="$here/../scripts/check-sources.js"
pass=0; fail=0
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

ok()  { if [[ "$2" == "$3" ]]; then pass=$((pass+1)); else fail=$((fail+1)); printf 'FAIL %s\n  want: %s\n  got:  %s\n' "$1" "$3" "$2"; fi; }
has() { if grep -q "$3" <<<"$2"; then pass=$((pass+1)); else fail=$((fail+1)); printf 'FAIL %s (missing %s)\n  got: %s\n' "$1" "$3" "$2"; fi; }

run() { node "$check" "$1" 2>&1; }
code() { node "$check" "$1" >/dev/null 2>&1; echo $?; }

good='{"version":1,"updated":"2026-10-17",
 "components":[{"id":"a","url":"https://a.test","for":["table"],"stack":"react","licence":"MIT"}],
 "screens":[{"id":"b","url":"https://b.test","for":["dashboard"],"stack":"react","licence":"MIT"}],
 "rejected":[{"url":"https://c.test","reason":"paid"}]}'

printf '%s' "$good" > "$tmp/good.json"
ok   "a good file passes" "$(code "$tmp/good.json")" "0"
has  "it counts the sources" "$(run "$tmp/good.json")" "2 sources, 1 rejected"

bad() { python3 -I -c "
import json,sys
d=json.loads(open('$tmp/good.json').read())
exec(sys.argv[1])
open('$tmp/bad.json','w').write(json.dumps(d))
" "$1"; }

bad "d['components'][0].pop('licence')"
ok   "a missing licence fails" "$(code "$tmp/bad.json")" "1"
has  "it names the field" "$(run "$tmp/bad.json")" "has no licence"

bad "d['screens'][0]['id']='a'"
has  "a repeated id is caught" "$(run "$tmp/bad.json")" "repeats"

bad "d['screens'][0]['url']='https://a.test'"
has  "a repeated url is caught" "$(run "$tmp/bad.json")" "repeats"

bad "d['rejected'].append({'url':'https://a.test','reason':'x'})"
has  "a source that is also rejected is caught" "$(run "$tmp/bad.json")" "also listed"

bad "d['components'][0]['url']='a.test'"
has  "a url without a scheme is caught" "$(run "$tmp/bad.json")" "not a url"

bad "d['components'][0]['for']=[]"
has  "an empty for list is caught" "$(run "$tmp/bad.json")" "is empty"

bad "d['components'][0]['for']='table'"
has  "a for that is not an array is caught" "$(run "$tmp/bad.json")" "must be an array"

bad "d['updated']='17-10-2026'"
has  "a bad date is caught" "$(run "$tmp/bad.json")" "YYYY-MM-DD"

bad "d['version']=2"
has  "a wrong version is caught" "$(run "$tmp/bad.json")" "version must be 1"

bad "d['rejected'][0].pop('reason')"
has  "a rejection without a reason is caught" "$(run "$tmp/bad.json")" "has no reason"

printf 'not json' > "$tmp/broken.json"
ok   "an unreadable file exits 2" "$(code "$tmp/broken.json")" "2"
ok   "a missing file exits 2" "$(code "$tmp/absent.json")" "2"

ok   "the shipped file is valid" "$(code "$here/../sources.json")" "0"

# patterns is optional, and validated when present
has "the shipped file counts patterns" "$(run "$here/../sources.json")" "21 sources"
python3 -I -c "
import json
d=json.loads(open('$tmp/good.json').read())
d['patterns']=[{'id':'p','url':'https://p.test','for':['status'],'stack':'any','licence':'MIT'}]
open('$tmp/pat.json','w').write(json.dumps(d))
"
ok   "a file with patterns passes" "$(code "$tmp/pat.json")" "0"
has  "patterns are counted" "$(run "$tmp/pat.json")" "3 sources"
python3 -I -c "
import json
d=json.loads(open('$tmp/good.json').read())
d['patterns']='no'
open('$tmp/pat2.json','w').write(json.dumps(d))
"
has  "a patterns field that is not an array is caught" "$(run "$tmp/pat2.json")" "must be an array"

printf '%s passed, %s failed\n' "$pass" "$fail"
(( fail == 0 ))
