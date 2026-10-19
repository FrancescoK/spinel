# A nil stored into an Array through a name that a conditional chose, when
# that name can also be nil or holds a boxed value, lands in the Array every
# other name reads: the element read later is nil, so calling a method on it
# raises NoMethodError, as in CRuby. The store goes back through an if
# without else, a ternary, a case, an or, a rescue modifier and a method
# that answers one of the choices, and through a method's parameter.
class K
  def initialize(v); @v = v; end
  def v; @v; end
end

class Holder
  def initialize; @items = [K.new(1)]; end
  def items; @items; end
  def total; @items.map { |q| q.v }; end
end

def plain = [K.new(5)]
def push_nil(a) = a << nil
def gap(a) = (a[3] = K.new(2))
def pick(n, h) = n == 0 ? h.items : pick(n - 1, h)

def report(h)
  p h.total
rescue NoMethodError => e
  puts e.message
end

n = ARGV.size

h = Holder.new
c = (h.items if n == 0)
c << nil
report(h)

h = Holder.new
c = n == 0 ? h.items : nil
c << nil
report(h)

h = Holder.new
c = case n when 1 then plain when 0 then h.items end
c << nil
report(h)

h = Holder.new
c = (n == 0 ? h.items : nil) || plain
c << nil
report(h)

h = Holder.new
c = (n == 0 ? h.items : plain) rescue plain
c << nil
report(h)

h = Holder.new
pick(n + 3, h) << nil
report(h)

h = Holder.new
c = (h.items if n == 0)
push_nil(c)
report(h)

h = Holder.new
c = case n when 1 then plain when 0 then h.items end
push_nil(c)
report(h)

h = Holder.new
c = (n == 0 ? h.items : plain) rescue plain
gap(c)
report(h)

h = Holder.new
c = (n == 0 ? h.items : nil) || plain
gap(c)
report(h)

h = Holder.new
c = case n when 1 then plain else h.items end
c << nil
report(h)

h = Holder.new
c = begin
  n == 0 ? h.items : plain
rescue
  plain
end
c << nil
report(h)

# a store that stays on the other Array leaves the Holder's alone
h = Holder.new
c = (n == 1 ? h.items : nil) || plain
c << nil
report(h)
p c.size
