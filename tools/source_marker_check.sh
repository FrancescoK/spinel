#!/bin/sh
# #<SPINEL_SOURCE>file:line (#7630): the lines after the marker are reported at
# that position, and what the program does does not change.
SPINEL=${SPINEL:-bin/spinel}
tmp=$(mktemp -d "${TMPDIR:-/tmp}/spinel-srcmark.XXXXXX") || exit 2
trap 'rm -rf "$tmp"' EXIT
ok=1
fail() { echo "source-marker-test: FAIL ($1)"; ok=0; }

cat > "$tmp/greeting.rb" <<'RB'
# generated from greeting.html.erb by a transpiler
def greeting(io, name)
#<SPINEL_SOURCE>greeting.html.erb:1
  io << "<p>Hello, "
  io << name.upcase
  io << "!</p>\n"
#<SPINEL_SOURCE>greeting.html.erb:2
  io << "<p>Seen from "
  io << File.basename(__dir__)
  io << "</p>\n"
  nil
end
RB
cat > "$tmp/main.rb" <<'RB'
require_relative "greeting"
io = String.new
greeting(io, "world")
print io
puts __LINE__
#<SPINEL_SOURCE>weird name.erb:7:3
puts __FILE__ == $0
#<SPINEL_SOURCE>nocolon
#<SPINEL_SOURCE>:5
#<SPINEL_SOURCE>x.erb:0
puts 1
RB
cd "$tmp" || exit 2
"$OLDPWD/$SPINEL" main.rb -o app 2>err.txt || { cat err.txt; fail "compile"; }
./app > got.txt
printf '<p>Hello, WORLD!</p>\n<p>Seen from %s</p>\n5\ntrue\n1\n' "$(basename "$tmp")" > want.txt
cmp -s got.txt want.txt || { diff want.txt got.txt; fail "the program's output changed (__dir__/__FILE__/__LINE__ stay physical)"; }
"$OLDPWD/$SPINEL" main.rb -S > out.c 2>/dev/null
grep -q '^#line 1 "greeting.html.erb"' out.c || fail "no #line 1 greeting.html.erb"
grep -q '^#line 2 "greeting.html.erb"' out.c || fail "no #line 2 greeting.html.erb"
grep -q '^#line 7 "weird name.erb:7"\|^#line 3 "weird name.erb:7"' out.c || fail "a path with a colon splits at the last one"
grep -q '^#line 2 "greeting.rb"' out.c || fail "lines before the first marker keep their place"
grep -q 'nocolon\|"x.erb"\|^#line [0-9]* ""' out.c && fail "a malformed marker was taken"
[ $ok -eq 1 ] && echo "source-marker-test: pass" || exit 1
