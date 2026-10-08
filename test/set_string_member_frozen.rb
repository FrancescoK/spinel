# An unfrozen String joins a Set as a frozen copy, as CRuby's Set takes it
# (the way a Hash takes a String key): changing the String afterwards leaves
# the member and its membership alone, and the member cannot be changed. A
# frozen String joins as itself. Covers every way a member gets in.
# spinel: share
def probe(label, st, s)
  e = st.find { |x| x == s }
  s << "!"
  p [label, st.include?(s.chomp("!")), st.include?(s), e.frozen?, e.equal?(s)]
end

probe(:add, Set.new.add(+"a"), +"a")
s = +"b"; probe(:add, Set.new.add(s), s)
s = +"c"; probe(:shovel, Set.new << s, s)
s = +"d"; probe(:add?, Set.new.add?(s), s)
s = +"e"; probe(:merge, Set.new.merge([s]), s)
s = +"f"; probe(:new, Set.new([s]), s)
s = +"g"; probe(:new_block, Set.new([1]) { s }, s)
s = +"h"; probe(:brackets, Set[s], s)
s = +"i"; probe(:union, Set[0] | [s], s)
s = +"j"; probe(:replace, Set[0].replace([s]), s)
s = +"k"; probe(:to_set, [s].to_set, s)
s = +"l"; probe(:map!, Set[1].map! { s }, s)

# an alias of the String changes it, not the member
s = +"m"; t = s
st = Set[s]
t << "?"
p [st.include?("m"), st.include?("m?"), st.to_a]

# the member itself is frozen
s = +"n"
begin
  Set[s].first << "x"
rescue FrozenError => e
  p e.class
end
p s

# a frozen String joins as itself
f = "lit"
p Set[f].first.equal?(f)
u = (+"u").freeze
p Set.new.add(u).first.equal?(u)
p Set[1].map! { u }.first.equal?(u)

# members that are not Strings are kept as they are
a = [1]
p Set[a].first.equal?(a)
p Set[1, :x, 2.5, nil].to_a
