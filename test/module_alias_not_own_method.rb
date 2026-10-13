# An alias an included module makes is the module's method, not one of the
# including class's own: instance_methods(false) leaves it out.

module Tr
  def on_b = 1
  alias_method :on_a, :on_b
  alias on_c on_b
end
class E
  include Tr
  def own = 2
  alias own2 own
end
p E.instance_methods(false).sort, E.public_instance_methods(false).sort
p E.instance_methods.include?(:on_a), E.new.methods.include?(:on_c), E.method_defined?(:on_a)
p Tr.instance_methods(false).sort
class F < E; end
p F.instance_methods(false)
