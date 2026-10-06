# A superclass written in parentheses is the class inside them; it used to
# be read as no superclass at all, so the class silently became a subclass
# of Object.
class Base
  def hi = "base"
end

module Outer
  class Inner < Base
    def hi = "inner"
  end
end

class A < (Base); end
class B < ((Outer::Inner)); end
class C < (::Base)
  def hi = super + "!"
end

p A.superclass
p A.new.hi
p B.superclass
p B.new.hi
p C.superclass
p C.new.hi
p C.ancestors.take(2)
