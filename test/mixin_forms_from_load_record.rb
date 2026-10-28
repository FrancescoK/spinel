# An include, extend or prepend the load record holds under a constant
# condition (`include A if true`, the else of `if false`, `unless false`)
# or in a `begin ... end` mixes the module in; the arm a constant condition
# skips does not, and neither does one in an iterator's block, which runs
# zero times or several.
module A; def a = "A"; end
module B; def b = "B"; end
module E; def e = "E"; end
module G; def g = "G"; end
module P; def tag = "P(" + super + ")"; end
class C
  include A if true
  include B if false
  if false
    extend G
  else
    extend E
  end
  prepend P unless false
  def tag = "C"
end
c = C.new
p c.respond_to?(:a), c.respond_to?(:b)
p C.e, C.respond_to?(:g)
puts c.tag
p C.ancestors.take(4)
p C.include?(A), C.include?(B)

class D
  def w = :D
  0.times { include B }
  0.times { extend E }
  0.times { prepend P }
  [].each { include G }
end
p D.new.respond_to?(:b), D.respond_to?(:e), D.new.respond_to?(:g)
p D.new.w
module W
  0.times { prepend P }
  def tag = "W"
end
class H; include W; end
puts H.new.tag
p H.ancestors.take(3)

class J
  begin
    include B
  end
end
p J.new.respond_to?(:b), J.include?(B)
