# Value queries retain the producer beyond a sequence's leading statements.
# spinel: gc-stress
s = +"abcd"
p (puts :chain; s.insert(0, "x")).slice!(0, 2)
p s
p (puts :fresh; "abc".dup).slice!(0, 2)
p (+(puts :literal; "abc")).slice!(0, 2)
p (puts :plain; s).slice!(0, 1)
p s
p "#{(puts :interpolation; "lit")}#{""}"
p "#{(puts :nil_interpolation; ())}#{""}"
def fresh_text
  (puts :fresh_tail; "abc".dup)
end
s = fresh_text
s << "d"
p s

# A sequence ending in a literal remains that frozen literal in interpolation.
e = "#{(1; "x")}#{""}"
p e.frozen?
a = "#{(puts :i; "lit")}#{""}"
begin
  a << "!"
rescue FrozenError
  puts :frozen
end
