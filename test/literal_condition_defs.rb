# A def under a condition its literals fix (false, nil, true, a comparison of
# two literals, a negation of one) is defined only on the branch that runs,
# as CRuby runs the body: in a class, a module and at the top level.
class Shape
  if false
    def hidden = 1
  else
    def shown = 2
  end
  unless true
    def gone = 3
  end
  if 1 == 2
    def never = 4
  end
  if "b" > "a" && true
    def kept = 5
  end
  if !nil
    def also = 6
  end
  if false
    unused = 1
  end
  p unused
end

module Helpers
  if :a != :a
    def nope = 1
  end
end

if nil
  def top_level_hidden = 1
end

p Shape.instance_methods(false).sort
p Shape.new.respond_to?(:hidden), Shape.new.shown
p Helpers.method_defined?(:nope)
p respond_to?(:top_level_hidden, true)
