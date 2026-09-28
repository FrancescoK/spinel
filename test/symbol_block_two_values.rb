# A Symbol's block over a call that passes its block several values calls
# the method on the first with the rest, as Symbol#to_proc does:
# `inject(&:concat)` is `inject { |a, b| a.concat(b) }`. The literal
# `&:concat` took only the first, so it called acc.concat with nothing and
# answered [1]; so did a Symbol constant over inject, a Symbol local over
# each_with_index, each_with_object or a Hash's select, and any of them over
# a method of the program that yields two values. An operator symbol over
# sort, min or max of Arrays or a Hash, and a Proc or a Symbol constant given
# to sort, min or max, ran no block at all. A method that yields one value
# keeps the one-value block.

# inject / reduce, with and without a seed
p [[1], [2], [3]].inject(&:concat)
p [[1], [2]].reduce(&:concat)
p [[1], [2]].inject([0], &:concat)
p [[1], [2]].inject([], &:push)
p [{ a: 1 }, { b: 2 }].inject(&:merge)
p [12, 18].inject(&:gcd)
p (1..4).reduce(2, &:lcm)
p [String.new("a"), "b"].reduce(String.new(">"), &:concat)
p({ 1 => 1, 2 => 3 }.inject(&:concat))
p [[1], [2]].each.inject(&:concat)

# the comparators
p %w[b a C].sort(&:casecmp)
p %w[b a C].sort!(&:casecmp)
p %w[b a C].max(&:casecmp)
p %w[b a C].min(2, &:casecmp)
p %w[b a C].minmax(&:casecmp)
p [[2], [1], [3]].sort(&:<=>)
p [[2], [1], [3]].max(&:<=>)
p [[2], [1], [3]].min(2, &:<=>)
p({ b: 1, a: 2 }.min(&:<=>))
p({ b: 1, a: 2 }.sort(&:<=>))
p [3, 1, 2].sort(&:<=>)
by_case = proc { |x, y| x.casecmp(y) }
p %w[b a C].sort(&by_case)
p %w[b a C].sort!(&by_case)
p %w[b a C].max(2, &by_case)
desc = ->(x, y) { y <=> x }
p [1, 3, 2].sort(&desc)
p [1, 3, 2].min(&desc)
p [1, 3, 2].minmax(&desc)
def sorted(x, &b) = x.sort(&b)
def top2(x, &b) = x.max(2, &b)
p sorted([3, 1, 2])
p(sorted([3, 1, 2]) { |x, y| y <=> x })
p top2([3, 1, 2])
p(top2([3, 1, 2]) { |x, y| y <=> x })

# an element and its index or memo, a Hash's key and value
a = [[1], [2]]
a.each_with_index(&:push)
p a
a = [[1], [2]]
a.each_with_index(&:<<)
p a
a = [[1], [2]]
p a.each_with_object([9], &:concat)
p a
p [10, 20].map.with_index(1, &:+)
h = { 1 => 1, 2 => 3 }
p h.select(&:eql?)
p h.reject(&:==)
p h.filter(&:<)
h.delete_if(&:eql?)
p h
p({ 1 => 1, 2 => 3 }.to_h(&:divmod))
p [1, 2, 2, 3].chunk_while(&:eql?).to_a
p [1, 2, 2, 3].slice_when(&:eql?).to_a
p [1, 2, 4, 5].chunk_while { |x, y| y - x - 1 }.to_a

# a Symbol in a local or a constant
s = :concat
p [[1], [2], [3]].inject(&s)
C = :concat
p [[1], [2], [3]].reduce(&C)
OP = :+
p [1, 2, 3].reduce(&OP)
s = :push
a = [[1], [2]]
a.each_with_index(&s)
p a
s = :eql?
p({ 1 => 1, 2 => 3 }.select(&s))
s = :divmod
p({ 1 => 1, 2 => 3 }.to_h(&s))
s = :eql?
p [1, 1, 2].chunk_while(&s).to_a
p [1, 1, 2].slice_when(&s).to_a
CMP = :casecmp
p %w[b a C].sort(&CMP)
p %w[b a C].max(&CMP)
p %w[b a C].min(2, &CMP)
CAT = :concat
p [[1], [2]].inject([0], &CAT)

# through a method, a class method, send, a poly receiver, safe navigation,
# and a block the method yields to
def cat(x) = x.inject(&:concat)
def cat_seeded(x) = x.inject([0], &:concat)
def pick(h) = h.select(&:eql?)
p cat([[1], [2]])
p cat_seeded([[1], [2]])
p pick({ 1 => 1, 2 => 3 })

class Cat
  def self.cat(x) = x.reduce(&:concat)
end
p Cat.cat([[1], [2]])
p [[1], [2]].send(:inject, &:concat)
v = ARGV.empty? ? [[1], [2]] : { a: 1 }
p v.inject(&:concat)
w = ARGV.empty? ? [[1], [2]] : nil
p w&.inject(&:concat)
def twice(x) = yield(x.inject(&:concat))
p(twice([[1], [2]]) { |r| r.size })
p [[1], [2]].map { |x| [x].inject([0], &:concat) }

# an Enumerable of its own, from outside and on self
class Pairs
  include Enumerable
  def each
    yield [1]
    yield [2]
  end
  def cat = inject(&:concat)
end
p Pairs.new.inject(&:concat)
p Pairs.new.inject([9], &:concat)
p Pairs.new.cat

# a method of the program that yields several values, or calls its &b with them
def two = yield([1], [2])
def two_call(&b) = b.call([1], [2])
def three = yield(5, 1, 3)
def sum_pair = yield(3, 4)
def grow = yield([1], 2)
p two(&:concat)
p grow(&:push)
p grow(&:<<)
p two_call(&:concat)
p three(&:clamp)
p sum_pair(&:+)
joined = :concat
p two(&joined)
p two(&CAT)
class Pair
  def pair = yield([1], [2])
  def self.pair = yield([5], [6])
  def go = pair(&:concat)
end
p Pair.new.pair(&:concat)
p Pair.pair(&:concat)
p Pair.new.go

# a method of the same name that yields one value
class Box
  def inject = yield(5)
  def each_with_index = yield(6)
  def go = inject(&:succ)
  def go_with(sym) = inject(&sym)
end
p Box.new.inject(&:succ)
p Box.new.each_with_index(&:pred)
p Box.new.go
p Box.new.go_with(:succ)
