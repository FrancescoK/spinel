#!/bin/sh
# Three repeated alias write lists must not multiply the receiver walk's work.
n=${1:-64}
cat <<'RUBY'
class PivsProbe
  def initialize = @slot = :initial
end
PivsProbe.new
h = {a: 1}
b = [h, 1][ARGV.size]
RUBY
for pair in 'x b' 'y x' 'z y'; do
  set -- $pair
  i=0
  while [ "$i" -lt "$n" ]; do
    echo "$1 = $2"
    i=$((i + 1))
  done
done
echo 'z.instance_variable_set(:@slot, 5)'
echo 'p h'
