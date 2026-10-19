# Object#methods on a builtin value lists what the program adds to the
# value's class or to every object, ahead of the calls that ask; a private
# method, an undefined one and a top-level def are not listed. true and
# false each list their own class's.
module Twice
  def twice = self * 2
end
class Integer
  include Twice
  def half = self / 2
  private def secret = 1
  protected def guarded = 2
  undef_method :pred
end
class Object
  def everywhere = 1
end
def toplevel = 1
class FalseClass
  def only_false = :f
end
m = 4.methods
p m.include?(:twice), m.include?(:half), m.include?(:secret), m.include?(:guarded)
p m.include?(:pred), m.include?(:everywhere), m.include?(:toplevel)
p 4.public_methods.include?(:guarded), nil.methods.include?(:everywhere)
p 4.half, 4.twice, toplevel
p m.size, 4.public_methods.size, nil.methods.size
v = [4, nil].first
p v.methods.size, v.public_methods.size
f = ARGV.size > 5
nf = [nil, false][ARGV.size + 1]
bx = [false, 1][ARGV.size]
p f.methods.include?(:only_false), true.methods.include?(:only_false)
p nf.methods.include?(:only_false), bx.public_methods.include?(:only_false)
