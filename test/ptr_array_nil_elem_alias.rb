# An Array is a reference: a nil stored into it, or a gap left in it,
# through one name reaches every other name of it. A call on an element
# read through another name raises CRuby's NoMethodError for nil instead of
# running with a NULL self: a local copied from it, a parameter it is
# passed as (a method that stores into it, or keeps it in an ivar), the
# ivar a reader or a method hands out, a block a method yields it to, a
# module's method on an includer's ivar, a method's value and a mutator's.
# An Array.new block that can answer nil fills it with nil too.

class K
  def initialize(v); @v = v; end
  def v; @v; end
end

def gap(x) = (x[3] = K.new(2))
def add(x, y) = (x << y)
def same(x) = x

class Box
  def initialize; @items = [K.new(1)]; end
  def items; @items; end
  def tot; @items.map { |q| q.v }; end
end

class Bag
  def initialize; @items = [K.new(1)]; end
  def get; @items; end
  def tot; @items.map { |q| q.v }; end
end

class Lender
  def initialize; @items = [K.new(1)]; end
  def each_list; yield @items; end
  def tot; @items.map { |q| q.v }; end
end

class Held
  def initialize(a); @items = a; end
  def tot; @items.map { |q| q.v }; end
end

class Keeper
  def initialize(a); @items = a; end
  def add_nil; @items << nil; end
end

module Nils
  def add_nil; @items << nil; end
end

class Mixed
  include Nils
  def initialize; @items = [K.new(1)]; end
  def tot; @items.map { |q| q.v }; end
end

def show(label)
  p yield
rescue NoMethodError => ex
  puts "#{label}: #{ex.message}"
end

a = [K.new(1)]
b = a
b << nil
show("local copy") { a.map { |q| q.v } }

c = [K.new(1)]
gap(c)
show("param gap") { c.map { |q| q.v } }

d = [K.new(1)]
add(d, nil)
add(d, K.new(3))
show("param push") { d.map { |q| q.v } }

bx = Box.new
it = bx.items
it[3] = K.new(2)
show("reader") { bx.tot }

bg = Bag.new
got = bg.get
got << nil
show("method value") { bg.tot }

ln = Lender.new
ln.each_list { |l| l << nil }
show("yield") { ln.tot }

e = [K.new(1)]
held = Held.new(e)
e << nil
show("kept param") { held.tot }

f = [K.new(1)]
Keeper.new(f).add_nil
show("kept param, stored there") { f.map { |q| q.v } }

mx = Mixed.new
mx.add_nil
show("module") { mx.tot }

g = [K.new(1)]
h = same(g)
h << nil
show("identity") { g.map { |q| q.v } }

m = [K.new(1)]
n = m.push(K.new(3))
n << nil
show("mutator value") { m.map { |q| q.v } }

s = Array.new(3) { |i| K.new(i) if i > 0 }
show("Array.new block") { s.map { |q| q.v } }

t = Array.new(3) { |i| i > 0 ? K.new(i) : nil }
show("Array.new ternary") { t.map { |q| q.v } }

# a copy is another Array: it holds the nil, the original does not
u = [K.new(1), K.new(2)]
w = u.dup
w << nil
show("copy") { u.map { |q| q.v } }
