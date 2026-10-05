# A bare `subclasses` in a class method -- a reopened Class's methods are
# every class's -- is sent to the class, as a bare `superclass` already
# is. activesupport's Class#descendants is
# `subclasses.concat(subclasses.flat_map(&:descendants))`. It raised
# NameError for an undefined local variable or method.
class Class
  def descendants = subclasses.concat(subclasses.flat_map(&:descendants))
  def kids = subclasses.map(&:name).sort
end
class A; end
class B < A; end
class C < B; end
class D < A; end
p A.kids
p A.descendants.map(&:name).sort
p C.descendants
