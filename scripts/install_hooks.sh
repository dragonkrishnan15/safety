#!/usr/bin/env sh
git_dir=$(git rev-parse --git-dir 2>/dev/null)
[ -z "$git_dir" ] && { echo "Error: Not in a git repository" >&2; exit 1; }
hook_file="$git_dir/hooks/pre-commit"
mkdir -p "$git_dir/hooks"
cat << 'EOF' > "$hook_file"
#!/bin/sh
debug=$(git grep -n "DEBUG-CT" 2>/dev/null)
if [ -n "$debug" ]; then
  echo "Commit blocked: Temporary DEBUG-CT instrumentation found:" >&2
  echo "$debug" >&2
  exit 1
fi
exit 0
EOF
chmod +x "$hook_file"
printf 'Git pre-commit hook installed at %s\n' "$hook_file"
