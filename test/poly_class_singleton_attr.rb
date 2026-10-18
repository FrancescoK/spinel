# A `class << self` attr_accessor read and written through a class held
# boxed (out of an Array, or a parameter a run-time-named send can fill
# with anything): each class's own slot, as `Name.x` takes it, and the
# value stored is evaluated once. A value that is no class keeps CRuby's
# NoMethodError. An alias of the writer or the reader reaches the same slot.

class Base
  class << self
    attr_accessor :features
    alias_method :flags=, :features=
    alias_method :flags, :features

    def hello(x) = [name, x]
  end
end

class Any < Base; end

class Other; end

def stamp(klass, n)
  klass.features = (n += 1; { n: n })
  [klass.features, n]
end

def relay(o, name, *args) = o.send(name, *args)

vals = [Any, Base, 1, Other]
x = vals[ARGV.size]
x.features = { a: 1 }
p Any.features, x.features, Base.features
p stamp(vals[ARGV.size + 1], 0)
p x.hello(2)
p relay(Any, :hello, 3)
[vals[2], vals[3]].each do |v|
  v.features = 1
rescue NoMethodError => e
  puts e.message
end

x.flags = { b: 2 }
p Any.features, x.flags

# a subclass's own accessor of the alias's name is behind no alias
class Own < Base
  class << self
    attr_accessor :flags
  end
end
o = [Own, 1][ARGV.size]
o.flags = 7
Own.flags = 8 if Own.flags == 7
p Own.flags, Own.features
