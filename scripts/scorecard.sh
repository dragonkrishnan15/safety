#!/usr/bin/env sh
numstat=$(git diff --numstat 2>/dev/null)
added=0; deleted=0; files=0
if [ -n "$numstat" ]; then
  while IFS="$(printf '\t')" read -r add del file; do
    [ -n "$add" ] && [ "$add" != "-" ] && added=$((added + add))
    [ -n "$del" ] && [ "$del" != "-" ] && deleted=$((deleted + del))
    files=$((files + 1))
  done <<EOF
$numstat
EOF
fi
debug_count=$(git grep -n "DEBUG-CT" 2>/dev/null | wc -l | tr -d ' ')
untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
net=$((added - deleted))
printf '{"files_changed":%s,"lines_added":%s,"lines_deleted":%s,"net_change":%s,"debug_ct_count":%s,"untracked_files":%s}\n' \
  "$files" "$added" "$deleted" "$net" "${debug_count:-0}" "${untracked:-0}"
