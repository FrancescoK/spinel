# Blockless Integer#upto / #downto with a bad `to` (an unknown keyword hash
# lands here, since neither method declares keywords): CRuby answers an
# Enumerator and only raises once it is iterated. With a block, the loop runs
# right away, so the same ArgumentError fires immediately.
e = 2.upto(foo: 1)
p e.class
r = (e.to_a rescue [$!.class, $!.message]); p r

e2 = 5.downto(foo: 1)
p e2.class
r2 = (e2.each { } rescue [$!.class, $!.message]); p r2

r3 = (2.upto(foo: 1) { |i| i } rescue [$!.class, $!.message]); p r3
r4 = (5.downto(foo: 1) { |i| i } rescue [$!.class, $!.message]); p r4

r5 = (1.upto("a").to_a rescue [$!.class, $!.message]); p r5
e6 = 3.upto(nil)
p e6.class
r6 = (e6.to_a rescue [$!.class, $!.message]); p r6

$called7 = false
def mk7
  $called7 = true
  99
end
e7 = 2.upto([mk7])
p $called7
r7 = (e7.to_a rescue [$!.class, $!.message]); p r7
