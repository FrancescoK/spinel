# An alias or alias_method named define_method is the program's own method too.
class AliasRegistry
  def call_it(name) = [name, yield]
  alias define_method call_it
  def run(name) = define_method(name) { 2 }
end
p AliasRegistry.new.run(:a)
