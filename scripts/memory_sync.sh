#!/usr/bin/env sh
category="${1:-learned_quirks}"; entry="$2"
[ -z "$entry" ] && exit 0
mem_dir=".master-skill"
mem_file="$mem_dir/memory.json"
mkdir -p "$mem_dir"
[ ! -f "$mem_file" ] && printf '{"updated_at":"","architectural_decisions":[],"learned_quirks":[],"tooling_preferences":{},"historical_known_red":[]}' > "$mem_file"
now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
if command -v node >/dev/null 2>&1; then
  node -e "
    const fs = require('fs');
    const d = JSON.parse(fs.readFileSync('$mem_file'));
    d.updated_at = '$now';
    if (!d['$category']) d['$category'] = [];
    if (!d['$category'].includes('$entry')) d['$category'].push('$entry');
    fs.writeFileSync('$mem_file', JSON.stringify(d, null, 2));
  "
fi
printf 'Memory recorded to %s\n' "$mem_file"
