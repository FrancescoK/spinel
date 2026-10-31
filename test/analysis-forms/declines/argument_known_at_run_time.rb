# The class-body macro form declines: an argument the evaluator cannot compute.
class Base
  def self.mk(n) = define_method(n) { 1 }
end
class Foo < Base
  mk :"a#{ARGV.size}"
end
p Foo.new.a0
