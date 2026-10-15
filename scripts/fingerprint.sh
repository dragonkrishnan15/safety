#!/usr/bin/env sh
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
sha=$(git rev-parse HEAD 2>/dev/null || echo "")
dirty=$(git status --porcelain=v1 2>/dev/null | wc -l | tr -d ' ')
node_v=$(node -v 2>/dev/null || echo "")
py_v=$(python3 --version 2>/dev/null || python --version 2>/dev/null || echo "")
pkg="none"
[ -f "pnpm-lock.yaml" ] && pkg="pnpm"
[ -f "yarn.lock" ] && pkg="yarn"
[ -f "package-lock.json" ] && pkg="npm"
[ -f "poetry.lock" ] && pkg="poetry"
[ -f "uv.lock" ] && pkg="uv"
printf '{"os":"%s","shell":"%s","git":{"branch":"%s","sha":"%s","dirty_count":%s},"runtimes":{"node":"%s","python":"%s"},"package_manager":"%s"}\n' \
  "$(uname -s)" "$SHELL" "$branch" "$sha" "${dirty:-0}" "$node_v" "$py_v" "$pkg"
