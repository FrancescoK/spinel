# A Struct or Data read out of a mixed Array answers deconstruct_keys like a
# plain one: nil is every member, more keys than members is {}, and the first
# key naming no member ends the hash. A Struct also takes an index. With
# `&.`, a boxed Hash answers itself too (this did not compile).
S = Struct.new(:a, :b)
D = Data.define(:x, :y)

def t
  p yield
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

s = [S.new(1, 2), 5][0]
d = [D.new(x: 1, y: 2), 5][0]
t { s.deconstruct_keys([:a]) }
t { s.deconstruct_keys(nil) }
t { s.deconstruct_keys([:b, :a]) }
t { s.deconstruct_keys([:a, :z]) }
t { s.deconstruct_keys([:z, :a]) }
t { s.deconstruct_keys([:a, :b, :a]) }
t { s.deconstruct_keys(["a"]) }
t { s.deconstruct_keys([-1, 0]) }
t { s.deconstruct_keys(1) }
t { d.deconstruct_keys([:y]) }
t { d.deconstruct_keys(nil) }
t { d.deconstruct_keys([0]) }
t { [{a: 1}, 5][0].deconstruct_keys([:b]) }
t { s&.deconstruct_keys([:b]) }
h = [{a: 1}, 5][0]
t { h&.deconstruct_keys(nil) }
