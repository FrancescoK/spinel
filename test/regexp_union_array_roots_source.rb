# spinel: gc-stress
# Regexp.union joins each part's source into the pattern it compiles, over
# an Array at run time or over the arguments the emitter sees. The source
# joined so far was held in a C local while the next part's escape or to_s
# allocated, and under SPINEL_GC_STRESS=2 the collector freed it: the join
# read freed bytes. The parts mix Regexps (with and without flags) and
# Strings that need escaping.
parts = [/ab+/, "c.d", /e(f|g)/i, "h*", /x/m, "y?z"]
u = Regexp.union(parts)
p u.source
p u.match?("abbb"), u.match?("c.d"), u.match?("cxd"), u.match?("EF"), u.match?("h*"), u.match?("hh")
p "--c.d--eg--y?z".scan(u)
def union_of(words)
  Regexp.union(words.map { |w| w + "!" } + [/[0-9]+/])
end
v = union_of(["a", "b", "c"])
p v.source, v =~ "zzb!", v =~ "z42"
w = Regexp.union(/ab+/, "c.d", /e(f|g)/i, "h*", /x/m)
p w.source, w.match?("EG"), w.match?("cxd")
