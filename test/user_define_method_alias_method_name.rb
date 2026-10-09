# The same holds for alias_method.
class AliasMethodRegistry
  def call_it(name) = [name, yield]
  alias_method :define_method, :call_it
  def run(name) = define_method(name) { 4 }
end
p AliasMethodRegistry.new.run(:b)
