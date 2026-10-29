#!/bin/sh
# N receiver uses of a constant that aliases a class (`A = Foo; A.bar(i)`),
# which rewrite_const_alias_receivers renames to the class, among N classes
# of other code. The rename must not make the load record's next answer
# rebuild its point map over the whole program: each use asked after the
# previous one's edit did, N uses and N rebuilds.
n=${1:-100}
cat <<'RUBY'
class Foo
  def self.bar(x) = x + 1
end
A = Foo
t = 0
RUBY
i=0
while [ "$i" -lt "$n" ]; do
  echo "class K$i"
  echo "  def m(x) = x + $i"
  echo "end"
  echo "t += A.bar($i) + K$i.new.m($i)"
  i=$((i + 1))
done
echo 'puts t'
