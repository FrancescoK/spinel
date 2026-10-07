# fetch with a block that takes the missing key, on a receiver that may be a
# Hash or an Array, the key a Symbol or a String literal. The fetch itself
# types the still untyped local as a Hash of that key type for one round of
# inference, the block's parameter takes the key's type, and the local is
# boxed a round later: the Hash arm's boxed key went straight into the typed
# slot and the C did not build.
def pick(n) = n > 0 ? {"a" => 1, :s => 2, 3 => 4} : [1, 2]
x = pick(1)

# a Symbol key
p x.fetch(:zz) { |sym| sym }
p x.fetch(:s) { |sym| sym }
p x.fetch(:zz) { |sym| sym.to_s * 2 }
p x.fetch(:zz) { |sym| sym == :zz }
p x.fetch(:zz) { |sym| "no #{sym}" }
p x.fetch(:zz) { |sym| sym.inspect.size }
p x.fetch(:zz) { |k| k[0] }
v = x.fetch(:zz) { |sym| sym.to_s }
v << "?"
p v

# a String literal key: frozen, as the literal is
w = pick(1)
p w.fetch("zz") { |lit| lit + "!" }
p w.fetch("a") { |lit| lit + "!" }
p w.fetch("zz") { |lit| lit.frozen? }
p w.fetch("zz") { |lit| lit.size }
kept = w.fetch("zz") { |lit| lit }
begin
  kept << "!"
rescue FrozenError
  puts "the key itself"
end
p kept
begin
  w.fetch("zz") { |own| own << "!" }
rescue FrozenError
  puts "frozen"
end

# the Array arm still raises for a key that is no index
y = pick(0)
begin
  y.fetch(:zz) { |sym| sym }
rescue TypeError
  puts "no index"
end
p y.fetch(7) { |i| i * 2 }
p y.fetch(1) { |i| i * 2 }

# keys of two kinds under one parameter name
p x.fetch(:zz) { |k| k }
p x.fetch(9) { |k| k }
p x.fetch(:zz) { 5 }
