#!/bin/sh
# Unrelated method bodies must not multiply a boxed Hash store's work.
n=${1:-64}
i=0
while [ "$i" -lt "$n" ]; do
  echo "def pad$i(x) = x + $i"
  i=$((i + 1))
done
cat <<'RUBY'
def pick(i) = [{a: 1}, [1, 2]][i]
pick(ARGV.size)[0] = 5
p pick(0)
RUBY
