#!/usr/bin/env sh
debug_matches=$(git grep -n "DEBUG-CT" 2>/dev/null || echo "")
debug_count=$(echo "$debug_matches" | grep -v '^$' | wc -l | tr -d ' ')
untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
diff_stat=$(git diff --stat 2>/dev/null)
crlf_check=$(git diff --check 2>/dev/null)
has_diff="false"; [ -n "$diff_stat" ] && has_diff="true"
has_crlf="false"; [ -n "$crlf_check" ] && has_crlf="true"
printf '{"debug_ct_count":%s,"untracked_count":%s,"has_diff":%s,"has_whitespace_or_crlf_errors":%s}\n' \
  "${debug_count:-0}" "${untracked:-0}" "$has_diff" "$has_crlf"
