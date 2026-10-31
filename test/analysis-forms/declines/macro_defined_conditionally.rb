# The class-body macro form declines: a macro its class may not define at the call.
class Foo
  if ARGV.empty?
    def self.mk(n) = define_method(n) { 1 }
  end
  mk :a
end
p Foo.new.a
