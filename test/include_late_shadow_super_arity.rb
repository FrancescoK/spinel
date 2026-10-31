# A reopening includes a module whose method has another arity than the
# superclass's method of that name, after a call ran on the class. Until
# the include runs, the call reaches the superclass's method with the
# arguments it was given; the hidden method the guard entry falls back to
# takes the superclass's parameters, not the module method's.
class Parent
  def value(x) = x * 2
end
module M
  def value = :m
end
class Child < Parent
end
p Child.new.value(7)
class Child
  include M
end
p Child.new.value

class Base
  def tag = "base"
end
module N
  def tag(x) = "n#{x}"
end
class Kid < Base
end
p Kid.new.tag
class Kid
  include N
end
p Kid.new.tag(1)
