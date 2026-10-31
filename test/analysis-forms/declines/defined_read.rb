# The class-body macro form declines: a block that asks defined? of a frame local.
class Base
  def self.mk(n)
    v = 1
    define_method(n) { defined?(v) }
  end
end
class Foo < Base
  mk :a
end
p Foo.new.a
