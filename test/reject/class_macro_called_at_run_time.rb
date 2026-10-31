# A class's macro called at run time, outside any class body: no form runs
# it at compile time, and its define_method's name is computed, so both
# load models refuse it.
class Base
  def self.mk(n) = define_method(n) { n.to_s }
end
class Foo < Base; end
Foo.mk(:a)
Foo.mk(ARGV.empty? ? :b : :c)
p Foo.new.a, Foo.new.b
