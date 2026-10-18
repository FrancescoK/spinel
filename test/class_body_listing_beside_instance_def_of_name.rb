# A class body's bare instance_methods(false) lists the class's own methods
# even where another class defines an instance method of that name
# (activesupport's DeprecationProxy delegates instance_methods): only a
# definition the class itself answers -- a class method, one in its
# singleton class, or one Module, Class or Object gains -- takes the call.
class Proxy
  def instance_methods(*) = :proxied
  def method_defined?(*) = :proxied
end

class FV
  CACHE = {}
  def accept(n, seed) = send(CACHE.fetch(n), n, seed)
  def visit_DOT(n, seed) = [:dot, seed]
  def visit_LIT(n, seed) = [:lit, seed]
  instance_methods(false).each do |pim|
    next unless pim.start_with?("visit_")
    CACHE[pim.name.delete_prefix("visit_").to_sym] = pim
  end
  p method_defined?(:visit_DOT)
end
p FV::CACHE.keys.sort, FV.new.accept(:LIT, 3), Proxy.new.instance_methods
