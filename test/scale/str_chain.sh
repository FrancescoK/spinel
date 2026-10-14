#!/bin/sh
# A String built by a chain of n appends, as generated template code writes
# it, and a chain of n bangs on another. Each pass that asks infer_type of
# every node re-inferred the chain below that node, n^2/2 inferences a pass,
# until an answer could outlive its query (#8852).
n=${1:-100}
printf 's = +"<p>"\ns'
i=0
while [ "$i" -lt "$n" ]; do
  printf ' << "x%d"' "$i"
  i=$((i + 1))
done
printf '\nt = +"Ab"\nt'
i=0
while [ "$i" -lt "$n" ]; do
  if [ $((i % 2)) -eq 0 ]; then printf '.upcase!'; else printf '.downcase!'; fi
  i=$((i + 1))
done
printf '\np s.size, t\n'
