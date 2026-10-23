# A `send` whose name is a method's answer is lowered into an arm per method
# the receiver may have. An arm is no statement of the program: which method
# the send runs is the run time's, and CRuby finds a module's method through
# it only once the module is mixed in. So a module a later statement mixes
# into the class is not reached "early" through the arm, and the program is
# not refused for it. Rails' Module#redefine_method sends the visibility it
# computed, and the arm for `concerning` stopped the program at
# `class Module; include Concerning; end`.
module Concerning
  def concerning(topic) = puts("concerning #{topic}")
end
class Module
  def visibility_of(method)
    private_method_defined?(method) ? :private : :public
  end
  def apply_visibility(method)
    visibility = visibility_of(method)
    send(visibility, method)
    method
  end
end
class Box
  def hi = "hi"
  apply_visibility :hi
end
puts Box.new.hi
class Module
  include Concerning
end
puts Box.new.hi.upcase
