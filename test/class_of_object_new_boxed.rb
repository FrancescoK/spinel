# An object's class read into a boxed slot (an Array that map fills with
# `.class`, a Hash value) is a Class value a later `new` dispatches on: it
# makes an instance of that class, as a constant's Class value does.
class A
  def initialize(n = 0) = @n = n
  def call = "A#{@n}"
end

class B < A
  def call = "B#{@n}"
end

k = [A.new].map(&:class).first
p k
p k.new(3).call
ks = [A.new, B.new(1)].map { |o| o.class }
p ks.map { |c| c.new(4).call }
h = { a: B.new.class }
p h[:a].new(5).call
p ks.first == A
p ks.last.equal?(B)
p ks.uniq.size
