# `k.instance_method(:m).bind_call(obj, args...)` where only the run time
# knows the class k holds (a parameter, a slot of mixed values) binds the
# `m` of that class: each class's own, an inherited one, an override. obj
# must be an instance of the method's owner, else TypeError, and a class
# without `m` raises NameError before obj and the arguments run. The same
# with a boxed obj on a constant's method. Such a call fell through to a
# call on a value of unknown type and raised "undefined method 'bind_call'
# for unknown", or was refused.

class Shape
  def initialize(n) = @n = n
  def area(scale = 1, round: false) = round ? (@n * scale).round : @n * scale
  def label(pre) = "#{pre}#{self.class}:#{@n}"
  def nothing(x) = nil
end
class Square < Shape
  def area(scale = 1, round: false) = [:sq, @n * @n * scale, round]
end
class Circle < Shape
end
class Rock
  def label(pre) = "#{pre}rock"
end
module Plain
  def other = 0
end

def area_of(k, o, *a, **kw) = k.instance_method(:area).bind_call(o, *a, **kw)
p area_of(Shape, Shape.new(3))
p area_of(Shape, Square.new(3), 2)
p area_of(Square, Square.new(3), 2, round: true)
p area_of(Circle, Circle.new(1.25), 2, round: true)

def label_of(k, o) = k.instance_method(:label).bind_call(o, ">")
p label_of(Shape, Circle.new(1))
p label_of(Rock, Rock.new)

def try
  p yield
rescue TypeError, NameError, NoMethodError => e
  puts "#{e.class}: #{e.message}"
end
try { label_of(Square, Shape.new(1)) }
try { label_of(Rock, Square.new(1)) }
try { area_of(Rock, Rock.new) }
try { area_of(Plain, Rock.new) }

# a slot of mixed values; obj and the arguments run once, in order
log = []
ks = [Square, Circle, Rock, 7]
ks.each do |k|
  try { k.instance_method(:area).bind_call((log << "o"; Square.new(2)), (log << "a"; 3)) }
end
p log
try { Rock.instance_method(:area).bind_call((log << "never"; 1)) }
p log
v = [Shape, 1][0]
p v.instance_method(:nothing).bind_call(Circle.new(0), 5)

# a boxed obj on a constant's method
objs = [Square.new(4), Rock.new, "s"]
objs.each { |o| try { Shape.instance_method(:label).bind_call(o, "+") } }
