# Object#methods on a builtin value lists what the program adds to the
# value's class or to every object, ahead of the calls that ask; a private
# method, an undefined one and a top-level def are not listed.
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
m = 4.methods
p m.include?(:twice), m.include?(:half), m.include?(:secret), m.include?(:guarded)
p m.include?(:pred), m.include?(:everywhere), m.include?(:toplevel)
p 4.public_methods.include?(:guarded), nil.methods.include?(:everywhere)
p 4.half, 4.twice, toplevel
p m.size, 4.public_methods.size, nil.methods.size
v = [4, nil].first
p v.methods.size, v.public_methods.size
