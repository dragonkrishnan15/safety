#!/usr/bin/env sh
# 1. Check for newly introduced DEBUG-CT in active code diff (excluding docs & tool scripts)
diff_debug=$(git diff -U0 -- ':!*.md' ':!*.mdc' ':!scripts/*' ':!adapters/*' 2>/dev/null | grep '^\+[^+].*DEBUG-CT' || echo "")
diff_count=$(echo "$diff_debug" | grep -v '^$' | wc -l | tr -d ' ')

# 2. Check for committed DEBUG-CT in code (excluding docs & tool scripts)
repo_debug=$(git grep -n "DEBUG-CT" -- ':!*.md' ':!*.mdc' ':!scripts/*' ':!adapters/*' 2>/dev/null || echo "")
repo_count=$(echo "$repo_debug" | grep -v '^$' | wc -l | tr -d ' ')

total_debug=$(( ${diff_count:-0} + ${repo_count:-0} ))
untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
diff_stat=$(git diff --stat 2>/dev/null)
crlf_check=$(git diff --check 2>/dev/null)
has_diff="false"; [ -n "$diff_stat" ] && has_diff="true"
has_crlf="false"; [ -n "$crlf_check" ] && has_crlf="true"

printf '{"debug_ct_count":%s,"untracked_count":%s,"has_diff":%s,"has_whitespace_or_crlf_errors":%s}\n' \
  "$total_debug" "${untracked:-0}" "$has_diff" "$has_crlf"
