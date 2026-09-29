# inject/reduce with an operator symbol over an array that reached a boxed
# value (here, from a method that can also return nil) folds through every
# Integer operator, not only + - * /.
def decode(bytes)
  return nil if bytes.empty?

  bytes.map { |b| b & 0xff }
end
d = decode([7, 1, 2])
p d.reduce(:^), d.reduce(:|), d.reduce(:&)
p d.inject(:<<), d.reduce(:>>), d.reduce(:**)
p decode([100, 7, 3]).reduce(:%)
p d.reduce(:+), d.reduce(:-), d.reduce(:*), decode([100, 7]).reduce(:/)
p decode([5]).reduce(:^)
begin
  d.reduce(:foo)
rescue NoMethodError => e
  p e.message
end
