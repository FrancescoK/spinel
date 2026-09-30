# Hash#rehash answers the receiver itself, whatever the Hash's key and
# value types, and raises FrozenError on a frozen one.
sym = {a: 1}
r1 = sym.rehash
p [r1.equal?(sym), r1]
str_int = {"a" => 1}
r2 = str_int.rehash
p [r2.equal?(str_int), r2]
int_int = {1 => 1}
r3 = int_int.rehash
p [r3.equal?(int_int), r3]
str_str = {"a" => "b"}
r4 = str_str.rehash
p [r4.equal?(str_str), r4]
int_str = {1 => "b"}
r5 = int_str.rehash
p [r5.equal?(int_str), r5]
mixed = {a: 1, "b" => 2}
r6 = mixed.rehash
p [r6.equal?(mixed), r6]
poly = {1 => 1, "b" => 2}
r7 = poly.rehash
p [r7.equal?(poly), r7]
empty = {}
r8 = empty.rehash
p [r8.equal?(empty), r8]

# chained, and as a statement
sym.rehash
p sym
p sym.rehash.rehash.equal?(sym)

# a key changed since it was stored is found again after rehash
a = [1, 2]
k = {a => 1}
a << 3
p k[a], k[[1, 2, 3]]
k.rehash
p k[a], k[[1, 2, 3]]

# frozen
f = {a: 1}.freeze
begin
  f.rehash
  p :no_error
rescue FrozenError => e
  p e.class
end
fs = {"a" => 1}.freeze
begin
  fs.rehash
  p :no_error
rescue FrozenError => e
  p [e.class, e.receiver.equal?(fs)]
end
fi = {1 => 1}.freeze
begin
  fi.rehash
  p :no_error
rescue FrozenError => e
  p [e.class, e.receiver.equal?(fi)]
end
