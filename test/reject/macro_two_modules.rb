# Two modules share a macro name and a class extends both: the one extended
# last answers in Ruby, and which that is depends on the class's extends, which
# are not followed. The call is not expanded (its run-time public_send refused),
# not expanded with the first module's macro.
module A
  module ClassMethods
    def constant(c) = const_set(c, public_send("a_#{c.to_s.downcase}"))
  end
end
module B
  module ClassMethods
    def constant(c) = const_set(c, public_send("b_#{c.to_s.downcase}"))
  end
end
class Calc
  extend A::ClassMethods
  extend B::ClassMethods
  def self.a_x = 1
  def self.b_x = 2
  constant :X
end
p Calc::X
