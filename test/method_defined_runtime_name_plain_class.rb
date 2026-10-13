# method_defined? with a name only the run time knows reads the reflection
# table, which a program with no other use of the class machinery wrote
# nothing of: the program did not link.
class Foo
  def a; end
  private def b; end
end

name = :a
p Foo.method_defined?(name), Foo.method_defined?(:z.to_s)
k = Foo
p k.method_defined?(:a), k.private_method_defined?(:b), k.public_method_defined?(:b)
