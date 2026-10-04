# A prepended module's method keeps its own visibility, and the class's own
# method under it keeps the class's. Visibility is registered by name before
# prepends, so the class's `private`/`protected` stayed on the name the
# module's copy took: a public module method over a private class one was
# refused as private, and a private one over a public one was called.
module A
  def greet = "A" + super
  private def hush = "a" + super
end

class L
  prepend A
  private def greet = "L"
  def hush = "l"
end

o = L.new
p o.greet
p((o.hush rescue $!.class))
p o.send(:hush)
p o.respond_to?(:greet), o.respond_to?(:hush)
p L.public_method_defined?(:greet), L.private_method_defined?(:hush)
p L.private_instance_methods(false).sort
p L.public_instance_methods(false).sort

module B
  def tick = "B" + super
end

class M
  prepend A
  prepend B
  protected def tick = "M"
  def run = tick
  private
  def greet = "M"
end

m = M.new
p m.tick, m.run, m.greet
p M.protected_instance_methods(false), M.private_instance_methods(false).sort
