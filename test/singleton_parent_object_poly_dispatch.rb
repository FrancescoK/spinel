# An object that later gets a singleton method (`def a.m`) is built by the
# singleton subclass's constructor, which stamps it with the parent's class id
# until that method is defined. Before then the object is an instance of the
# parent for a boxed receiver's dispatch, so the parent counts as built even
# though no `A.new` of its own is written: a call through an Array of mixed
# values reached no method of A and raised NoMethodError.
class A
  def initialize
    @x = 1
  end

  def show
    puts "A#show #{@x}"
  end

  def me
    self
  end

  def to_s
    "an A"
  end
end

class B < A
  def show
    puts "B#show"
  end
end

a = A.new
b = B.new
objs = [b, 7]
objs.push(a.me)
objs.each { |o| o.show if o.respond_to?(:show) }
puts "#{objs.last}"
def a.extra
  :extra
end
objs.each { |o| o.show if o.respond_to?(:show) }
puts a.extra
