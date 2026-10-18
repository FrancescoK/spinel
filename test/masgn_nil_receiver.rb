# A multiple assignment into an element or an attribute of a receiver that is
# nil raises NoMethodError, as the single assignment does, once the right side
# has run: an attribute of a nil object, an Integer, a String and an object
# Array. The typed Arrays' setters skip a NULL receiver without a word, and
# an attribute store read the field of NULL.
class Box
  attr_accessor :a, :b
end

class Pt
  def initialize(v); @v = v; end
  def v; @v; end
end

def show
  p yield
rescue NoMethodError => e
  puts e.message
end

def side(x)
  puts "rhs #{x}"
  x
end

n = ARGV.size

o = unless n == 0 then Box.new end
show { o.a, o.b = side(3), side(4); o }

o = nil
o = Box.new if n > 5
show { o.a, o.b = "s", "t"; o }

w = unless n == 0 then [1, 2, 3] end
show { w[0], w[1] = side(5), side(6); w }

w = n == 0 ? nil : ["p", "q"]
show { w[0], w[1] = "a#{n}", "b#{n}"; w }

w = case n when 3 then [Pt.new(1), Pt.new(2)] end
show { w[0], w[1] = Pt.new(7), Pt.new(8); w.map(&:v) }

w = unless n == 0 then [1, 2] end
w = [9, 9] if n == 0
show { w[0], w[1] = 3, 4; w }

# an Array an ivar holds, nil until it is set
class Holder
  def initialize; @i = nil; @s = nil; end
  def fill; @i = [1, 2]; @s = ["p", "q"]; end
  def go_i; @i[0], @i[1] = 3, 4; @i; end
  def go_s; @s[0], @s[1] = "a", "b"; @s; end
end

h = Holder.new
show { h.go_i }
show { h.go_s }
h.fill
show { h.go_i }
show { h.go_s }
