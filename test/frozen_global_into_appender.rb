# A frozen String held in a global and passed to a method that appends to
# its parameter raises FrozenError there. Under --share-strings the global
# holds the String's handle, but the call was refused as if it handed the
# method a copy of the global's bytes; it hands the handle itself.
def attempt(s)
  s << "x"
  "mutated"
rescue FrozenError
  "FrozenError"
end
def attempt_kw(s:)
  s << "x"
  "mutated"
rescue FrozenError
  "FrozenError"
end
s = +"gl"
$g = s.freeze
puts $g.equal?(s)
puts attempt($g)
puts attempt_kw(s: $g)
$g = +$g
puts attempt($g)
p $g, s
