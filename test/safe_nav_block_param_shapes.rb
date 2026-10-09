# spinel: share
# A block given to a builtin iterator through `&.` binds its parameters as
# it does through `.`: a block of two parameters spreads the one Array that
# then, yield_self or tap yields, and an optional, a post-required or a rest
# next to the requireds takes CRuby's value. A nil receiver answers nil and
# runs no block.

# then, yield_self and tap yield the receiver: two parameters spread it
def line_total(line) = line&.then { |qty, price| qty * price }
p line_total([2, 5]), line_total(nil)

def label(pair) = pair&.yield_self { |name, count| "#{name} x#{count}" }
p label(["apple", 3]), label(nil)

def show(pair) = pair&.tap { |name, count| puts "#{name}: #{count}" }
p show(["pear", 4]), show(nil)

def parsed(s) = [s.to_i, s.empty? ? nil : true]
yv = nil
cf = nil
parsed("31")&.then do |v, c|
  yv = v
  cf = c
end
p [yv, cf]
p parsed("7")&.then { |a, b| [a, b] }

# numbered parameters spread the same way
def bump(pair) = pair&.then { _1 + (_2 ? 1 : 0) }
p bump([7, true]), bump(nil)

# an optional next to a required takes its default
def defaults(nums) = nums&.map { |n, step = 10| n + step }
p defaults([1, 2]), defaults(nil)

def each_default(nums)
  nums&.each { |n, unit = "kg"| puts "#{n} #{unit}" }
end
p each_default([3, 4]), each_default(nil)

# a Hash yields a pair, which spreads across the key, a default and a rest
def entries(h)
  out = []
  h&.each { |k, v = 0, *rest| out << [k, v, rest] }
  out
end
p entries({ a: 1, b: 2 }), entries(nil)

# rows of an Array spread across a required and an optional
def rows(rs)
  out = []
  rs&.each { |a, b = 0| out << [a, b] }
  out
end
p rows([[1, 2], [3]]), rows(nil)

# combination yields one Array per step, which spreads across two parameters
def pairs(nums)
  out = []
  nums&.combination(2) { |q, r| out << [q, r] }
  out
end
p pairs([3, 1, 2]), pairs(nil)

# the same blocks over a receiver whose type is known at compile time
pair = [7, true]
p pair&.then { |a, b| [a, b] }
p pair&.yield_self { |a, b| [a, b] }
pair&.tap { |a, b| p [a, b] }
p pair&.then { _1 + (_2 ? 1 : 0) }
nums = [3, 1, 2]
p nums&.map { |n, step = 10| n + step }
nums&.each { |n, unit = "kg"| puts "#{n} #{unit}" }
nums&.combination(2) { |q, r| p [q, r] }
stock = { a: 1, b: 2 }
stock&.each { |k, v = 0, *rest| p [k, v, rest] }

# a local that holds an Array or nil spreads the Array, through `&.` and `.`
def cart_line(i) = i.even? ? [i, i + 1] : nil
2.times do |i|
  line = cart_line(i)
  p line&.then { |qty, price| qty * price }
end
[0, 2].each do |i|
  line = cart_line(i)
  p line.then { |qty, price| qty * price }
end
