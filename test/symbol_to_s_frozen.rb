# spinel: not-cruby
# Symbol#to_s answers the name frozen, as the program's string literals are:
# CRuby 4.0 answers a chilled String (not frozen yet, a mutation warns) and
# plans to freeze it; Spinel freezes it now. +@ and dup copy it, a mutation of
# the copy leaves the symbol's name alone, and a mutation of the name itself
# raises FrozenError, through each way a Symbol's to_s is reached.
s = :abc.to_s
p [s, s.frozen?, :abc.id2name.frozen?, String(:abc).frozen?]
p [[:abc, 1][0].to_s.frozen?, [:x, :y].map(&:to_s).map(&:frozen?), "dy#{s.size}".to_sym.to_s.frozen?]
t = +s
t << "!"
d = s.dup
d << "?"
p [s, t, d, t.frozen?, d.frozen?, (+s).equal?(s)]
[-> { s << "x" }, -> { :abc.id2name.upcase! }, -> { [:abc, 1][0].to_s.concat("y") },
 -> { String(:abc).replace("z") }].each do |f|
  f.call
rescue FrozenError => e
  p [e.class, e.message]
end
p [:abc.to_s, :abc.to_s + "+", :abc.to_s * 2, :abc.to_s.upcase]
