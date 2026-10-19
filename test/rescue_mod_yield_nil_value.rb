# A rescue modifier around a `yield` whose block answers nil or raises, beside
# a fallback of another kind (`(yield(0) rescue @a)`). The yield's value was
# assigned into a result slot of the fallback's kind, an int into an Array
# pointer, and the C did not build. A yield typed nil is emitted for its
# effect now and a pointer or nullable slot keeps its nil. A fallback whose
# kind has no nil of its own, a Range, a true or a false, answered its zero
# (`0..0`, false) where CRuby answers nil: that slot is boxed. A parenthesized
# yield is the same shape.
class C
  def initialize; @a = [1, 2, 3]; end
  def run
    (yield(0) rescue @a)
  end
end

def pick_array = (yield(0) rescue [1])
def pick_str = (yield(0) rescue "s")
def pick_int = (yield(0) rescue 7)
def pick_float = (yield(0) rescue 7.5)
def pick_sym = (yield(0) rescue :sym)
def pick_hash = (yield(0) rescue { 1 => 2 })

p C.new.run { |x| raise ArgumentError, "boom" }
p C.new.run { |x| nil }
p pick_array { |x| nil }
p pick_array { |x| raise "z" }
p pick_str { |x| nil }
p pick_str { |x| raise "z" }
p pick_int { |x| nil }
p pick_int { |x| raise "z" }
p pick_float { |x| nil }
p pick_float { |x| raise "z" }
p pick_sym { |x| nil }
p pick_sym { |x| raise "z" }
p pick_hash { |x| nil }
p pick_hash { |x| raise "z" }
p pick_array { |x| puts "ran"; raise "z" }
p pick_str { |x| puts "ran" }
v = (nil rescue 5)
p v
w = (puts("out") rescue [3])
p w

def pick_range = (yield rescue (1..2))
def pick_true = (yield rescue true)
def pick_false = (yield rescue false)
p pick_range { nil }
p pick_range { raise "z" }
p pick_true { nil }
p pick_true { raise "z" }
p pick_false { nil }
p pick_false { raise "z" }

class D
  def initialize; @a = [1, 2, 3]; end
  def run = ((yield(0)) rescue @a)
end
p D.new.run { |x| nil }
p D.new.run { |x| raise "z" }
