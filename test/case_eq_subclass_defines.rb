# A class that defines #== but not #===, beside a subclass that defines
# #===: an object of the class answers Kernel#===, which reaches its #==,
# and one of the subclass answers its own #===, wherever the object is held.
class Pattern
  def ==(o) = o.nil? ? false : true
end

class Strict < Pattern
  def ===(o) = false
end

p(Pattern.new === 1)
p(Pattern.new === nil)
p(Strict.new === 1)
p(Pattern.new != 3)

def make(plain) = plain ? Pattern.new : Strict.new
a = make(true)
b = make(false)
p(a === 1)
p(b === 1)
p(a != 1)
p(b != 1)

mixed = [Pattern.new, Strict.new]
p(mixed.map { |m| m === 1 })
p(mixed[1] === 1)

class Holder
  def initialize = @it = Pattern.new
  def put(v) = @it = v
  def test(v) = @it === v
end
h = Holder.new
p h.test(1)
h.put(Strict.new)
p h.test(1)

case 1
when a then puts "a matches"
else puts "a does not"
end
case 1
when b then puts "b matches"
else puts "b does not"
end

# beside a class's own #===, a boxed Proc's #=== answers the proc's value
pats = [Strict.new, ->(x) { x * 128 }, /ab/, 1..3, Integer, "s"]
pats.each do |pt|
  r = (pt === 2)
  puts r ? "y" : "n"
  case 2
  when pt then puts "when y"
  else puts "when n"
  end
end
p(pats[1] === 2)
