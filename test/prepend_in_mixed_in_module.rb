# A module that prepends another carries it in front of itself wherever it
# is mixed in: a class including or extending the module, or Class
# reopened with a prepend (every class's class methods), finds the
# prepended method first, and its super reaches the module's own.
module Loud
  def hi = "loud " + super
end

module Quiet
  def hi = "quiet"
  def bye = "bye"
  prepend Loud
end

class Includer
  include Quiet
end

class Extender
  extend Quiet
end

p Includer.new.hi
p Includer.new.bye
p Extender.hi
p Includer.ancestors.take(3)

module SkipB
  def descendants
    super.reject { |k| k.name == "B" }
  end
end

class Class
  def descendants
    subclasses.concat(subclasses.flat_map(&:descendants))
  end

  prepend SkipB
end

class A; end
class B < A; end
class C < A; end
class D < C; end
p A.descendants.map(&:name).sort
p C.descendants.map(&:name)
