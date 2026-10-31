# The class-body macro form declines: a definition query a fold answered before the walk.
class Base
  def self.mk(n) = define_method(n) { 1 }
end
class Foo < Base
  mk :m
  if !method_defined?(:m)
    def m = 2
  end
end
p Foo.new.m
