# A Struct built through a class value no analysis names
# (`Object.const_get(name).new`, a class read out of an Array) leaves the
# members past its arguments nil, as `S.new` with fewer arguments does: an
# Integer or Float member read 0 or 0.0 there, where CRuby has nil.
Victim = Struct.new(:a, :b)
seed = Victim.new(1, 0.5)
k = Object.const_get(ENV["SPINEL_TEST_NO_SUCH_VAR"] || "Victim")
v = k.new
p v, v.a, v.b
ks = [Victim, String]
w = ks[ARGV.size].new(7)
p w, w.b
p seed
Single = Struct.new(:x)
only_float = Single.new(2.5)
s = Object.const_get("Single").new
p s.x, only_float
