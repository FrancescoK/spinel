#!/usr/bin/env bash
# Run from the same built Linux checkout for both linkers.
# Set TEST_SHARD=1/4 for a shorter trial.
set -euo pipefail
export LANG=${LANG:-en_US.UTF-8} LC_ALL=${LC_ALL:-en_US.UTF-8}
out=${1:-build/lld-comparison}
shard=${TEST_SHARD:-1/1}
jobs=${TEST_JOBS:-$(getconf _NPROCESSORS_ONLN)}
target=${TEST_TARGET:-test-corpus}
case $target in test|test-corpus) ;; *) exit 2;; esac
[[ $(uname -s) = Linux ]]
[[ -x bin/spinel ]]
[[ ! -e $out ]] || { echo "Comparison directory already exists: $out" >&2; exit 2; }
mkdir -p "$out/linker-bin" "$out/measurements"
out=$(cd "$out" && pwd)
if ! command -v ld.lld >/dev/null; then
  version=$(clang -dumpversion)
  linker=$(command -v "ld.lld-${version%%.*}") || { echo "Install LLD for clang $version" >&2; exit 2; }
  ln -s "$linker" "$out/linker-bin/ld.lld"
  export PATH="$out/linker-bin:$PATH"
fi
printf 'int main(void) { return 0; }\n' | clang -fuse-ld=lld -x c - -o "$out/verify-lld"
printf 'int main(void) { return 0; }\n' | clang -x c - -o "$out/verify-default"
measure="$out/measurements"
readelf --string-dump .comment "$out/verify-lld" > "$measure/linker.txt"
readelf --string-dump .comment "$out/verify-default" > "$measure/default-linker.txt"
grep -E 'Linker: .*LLD' "$measure/linker.txt" || { cat "$measure/linker.txt" >&2; exit 2; }
if grep -qE 'Linker: .*LLD' "$measure/default-linker.txt"; then
  echo "Clang already defaults to LLD" >&2
  exit 2
fi
clang --version >> "$measure/linker.txt"
git rev-parse HEAD > "$measure/revision.txt"
printf '%s\n' "target=$target shard=$shard jobs=$jobs" | tee "$measure/settings.txt"
make -j"$jobs" -s test-pch OPT=-O0 CC=clang > "$measure/pch.log" 2>&1

run() {
  local mode=$1 warmth=$2 selector=$3
  local dir="$measure/$mode-$warmth"
  local results="$out/results-$mode-$warmth" rc=0
  mkdir -p "$dir" "$results"
  echo "Running $mode $warmth"
  RESULT_CACHE_DIR="$out/$mode-cache" /usr/bin/time -p -o "$dir/time.txt" \
    make -j"$jobs" "$target" OPT=-O0 CC=clang TEST_SHARD="$shard" \
    TEST_LD="$selector" GATE_CACHE=1 TEST_RESULT_DIR="$results" > "$dir/run.log" 2>&1 || rc=$?
  echo "$rc" > "$dir/status.txt"
  sed -n '/^Tests: /p' "$dir/run.log"
  find "$results" -name '*.cached' | wc -l > "$dir/cache-hits.txt"
  find "$results" -name '*.ok' | wc -l > "$dir/results-count.txt"
  cat "$dir/time.txt"
  if (( rc )); then tail -n 45 "$dir/run.log"; fi
}

run default cold ''
run lld cold lld
run lld warm lld
run default warm ''
{
  printf '| Linker | Cache | Wall seconds | User seconds | System seconds | Cache hits | Status |\n'
  printf '| --- | --- | ---: | ---: | ---: | ---: | ---: |\n'
  for mode in default lld; do
    for phase in cold warm; do
      dir="$measure/$mode-$phase"
      read -r wall user sys < <(awk '$1 == "real" || $1 == "user" || $1 == "sys" {printf "%s ", $2} END {print ""}' "$dir/time.txt")
      printf '| %s | %s | %s | %s | %s | %d | %d |\n' \
        "$mode" "$phase" "$wall" "$user" "$sys" "$(cat "$dir/cache-hits.txt")" "$(cat "$dir/status.txt")"
    done
  done
} | tee "$measure/summary.md"
for phase in cold warm; do
  for mode in default lld; do
    dir="$measure/$mode-$phase"
    [[ $(cat "$dir/status.txt") == 0 ]]
    grep -q '^Tests: ' "$dir/run.log"
  done
  diff -u "$measure/default-$phase/results-count.txt" "$measure/lld-$phase/results-count.txt"
  diff -u <(sed -n '/^Tests: /p' "$measure/default-$phase/run.log") \
          <(sed -n '/^Tests: /p' "$measure/lld-$phase/run.log")
done
