#!/usr/bin/env sh
cmd="$1"; max_runs="${2:-20}"; timeout_sec="${3:-60}"
start_time=$(date +%s); pass=0; fail=0
for i in $(seq 1 "$max_runs"); do
  now=$(date +%s)
  [ $((now - start_time)) -ge "$timeout_sec" ] && break
  if eval "$cmd" >/dev/null 2>&1; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1)); break
  fi
done
is_clean="false"; [ "$fail" -eq 0 ] && is_clean="true"
printf '{"total_runs":%s,"passed":%s,"failed":%s,"is_clean":%s,"elapsed_seconds":%s}\n' \
  "$((pass + fail))" "$pass" "$fail" "$is_clean" "$(( $(date +%s) - start_time ))"
