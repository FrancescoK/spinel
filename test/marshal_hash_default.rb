# Marshal writes a Hash with a default value as CRuby does: `}`, its pairs,
# then the default, and Marshal.load reads that back with the default, from
# Spinel's dump or CRuby's (the literal below). Every Hash kind carries one:
# String- or Symbol-keyed, Integer- or String-valued, and a general one. A
# Hash with a default proc is CRuby's TypeError; one without a default is
# written `{` as before.
g = Hash.new(5)
g[:k] = 1
p Marshal.dump(g)
h = Marshal.load(Marshal.dump(g))
p h, h[:zz], h.default

si = Hash.new(0)
si["a"] = 1
p Marshal.load(Marshal.dump(si))["b"], Marshal.dump(si)

ss = Hash.new("none")
ss["a"] = "x"
p Marshal.load(Marshal.dump(ss))["b"]

ii = Hash.new(-1)
ii[1] = 2
p Marshal.load(Marshal.dump(ii))[9]

pp1 = Hash.new([0])
pp1[[1]] = 2
p Marshal.load(Marshal.dump(pp1))[:q]

pl = {a: 1}
p Marshal.dump(pl), Marshal.load(Marshal.dump(pl)).default

nested = Marshal.load(Marshal.dump([g, {x: si}]))
p nested[0][:none], nested[1][:x]["none"]

p Marshal.load("\x04\b}\x06:\x06ki\x06i\n".b)[:zz]

pr = Hash.new { |hh, k| k }
begin
  Marshal.dump(pr)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
