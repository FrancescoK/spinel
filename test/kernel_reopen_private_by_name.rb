# A Kernel method made private by name (`private :m`, `module_function :m`)
# is not a public method of Object: an explicit receiver raises NoMethodError.
module Kernel
  def foo = "foo"
  private :foo
  def baz = "baz"
  module_function :baz
  def bar = "bar"
end
p bar
p 5.bar
p foo
begin; p 5.foo; rescue NoMethodError => e; p e.class; end
p baz
begin; p "s".baz; rescue NoMethodError => e; p e.class; end
