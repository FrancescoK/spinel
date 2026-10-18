# nil.to_h is an empty Hash, also where a program class defines to_h: on
# a receiver that is the object or nil, and on a boxed one.
class Pairs
  def initialize(h) = @h = h
  def to_h = @h
end

class Named
  def to_h = { "n" => 1 }
end

maybe = ARGV.size > 5 ? Pairs.new({ a: 1 }) : nil
p maybe.to_h
p Pairs.new({ b: 2 }).to_h

named = ARGV.size > 5 ? Named.new : nil
p named.to_h
p named.to_h.size

boxed = [Pairs.new({ c: 3 }), nil, [[:k, 4]], { d: 5 }]
boxed.each { |v| p v.to_h }

h = nil.to_h
h[:x] = 1
p h, nil.to_h
