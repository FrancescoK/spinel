# A nil stored through one name of an Array of objects (a store past its end
# leaves a gap) lands where every other name of it reads: the slot the Array
# was read out of is marked as holding one. The mark went back through an
# `if` and not through a case/in, so a call on an element of the Array a
# reader hands out ran with a NULL self and faulted where CRuby raises
# NoMethodError for nil.
class K
  def initialize(v); @v = v; end
  def v; @v; end
end

class Holder
  def initialize; @items = [K.new(1)]; end
  def items; @items; end
  def total; @items.map { |q| q.v }; end
end

def gap(x) = (x[3] = K.new(2))
def plain = [K.new(5)]

def show(label)
  p yield
rescue NoMethodError
  puts "#{label}: nil element"
end

def pick(h, n)
  case n
  in 0 then h.items
  else plain
  end
end

h = Holder.new
n = ARGV.size
b = case n
    in 0 then h.items
    else plain
    end
gap(b)
show("local") { h.total }

g = Holder.new
gap(pick(g, n))
show("method") { g.total }

k = Holder.new
gap(pick(k, n + 1))
show("other arm") { k.total }
