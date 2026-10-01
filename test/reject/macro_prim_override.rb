# The class gives const_set a method of its own: CRuby runs it for the macro's
# const_set, so the call is not expanded into a plain constant assignment
# (which would bypass the override); its run-time public_send is refused.
module Sizes
  def constant(c) = const_set(c, public_send("calc_#{c.to_s.downcase}"))
end
class Calc
  extend Sizes
  def self.const_set(name, v)
    puts "hooked #{name}"
    super(name, v * 2)
  end
  def self.calc_size = 32
  constant :SIZE
end
p Calc::SIZE
