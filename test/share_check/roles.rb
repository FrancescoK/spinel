# Each String value has a consumer, and the plan's need is that consumer's
# (#8328): an interpolation only reads the bytes, a bang call's own answer is
# only tested for nil (its receiver's handle is the answer), a multiple
# write stores each value into its target, and a method's tail is taken by
# its caller, which picks up the handle the tail publishes.
class Box
  def initialize(s) = @s = s
  def s = @s
end
s = +"ab"
box = Box.new(s)
puts "<#{s}>"
r = s.upcase!
x = (a, b = s, +"cd")
a << "!"
p r, x, box.s, box.s.equal?(s), b
puts "yes" if s
