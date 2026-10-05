# `Klass === x` where x is a String slot that can hold nil (a parameter that
# gets nil, a method that returns nil, an ivar written nil, a missed Hash
# key). The slot carries nil as NULL, so String and Comparable answer false
# for it and NilClass true; the roots hold for both. The operand is read once.
def str?(s) = String === s
p str?("a"), str?(nil)

def guard(s)
  unless String === s
    return :notstr
  end
  s.size
end
p guard("abc"), guard(nil)

$calls = 0
def maybe(i)
  $calls += 1
  i.odd? ? "s#{i}" : nil
end
p String === maybe(1), String === maybe(2)
p NilClass === maybe(1), NilClass === maybe(2)
p Comparable === maybe(1), Comparable === maybe(2)
p Object === maybe(2), BasicObject === maybe(2), Kernel === maybe(2)
p $calls

class Box
  def initialize = @v = nil
  def set(v) = @v = v
  def str? = String === @v
end
b = Box.new
p b.str?
b.set("x")
p b.str?

h = { a: "x" }
p String === h[:a], String === h[:b]
