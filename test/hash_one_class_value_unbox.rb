# A String-keyed Hash of one class's objects is a str_poly_hash: each read
# into an Item-typed slot is a checked unbox (sp_poly_unbox_cls). A value of
# exactly the wanted class takes the inline tag + class-id path; nil (a
# missing key) and anything else still take the full check.
class Item
  attr_reader :n
  def initialize(n) = @n = n
end

h = {}
keys = []
i = 0
while i < 50
  k = "k#{i}"
  keys << k
  h[k] = Item.new(i)
  i += 1
end
sum = 0
3.times do
  keys.each { |key| sum += h[key].n }
end
p sum
p h["k7"].n

# a read into a local the program also assigns an Item
it = Item.new(-1)
it = h["k9"]
p it.n

# a missing key reads nil, through the same unbox
miss = Item.new(-2)
miss = h["none"]
p miss
p miss.nil?
p(miss ? miss.n : -1)

# iteration still sees every value, in insertion order
total = 0
h.each_value { |v| total += v.n }
p total
p h.size

