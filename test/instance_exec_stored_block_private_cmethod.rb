# A block a method keeps, which instance_exec may run on another class,
# calls a private class method bare or through `self.`: self may call its
# private methods, so the call runs on whichever class the block is run
# with. Its call went through the boxed self's dispatch, which refused a
# private method as for an explicit receiver and raised NoMethodError.

HOOKS = []
def on_load(&blk) = HOOKS << blk

class Base
  def self.slug(s) = "base:#{s}"
  private_class_method :slug
end
class Ctl < Base
  def self.slug(s) = "ctl:#{s}"
  private_class_method :slug
end

class Base
  on_load { p [slug("a"), self.slug("b")] }
end

HOOKS.each { |h| h.call }
HOOKS.each { |h| Ctl.instance_exec(&h) }
begin
  Base.slug("c")
rescue NoMethodError => e
  puts e.message
end
