# A scoped constant path through a builtin class or module does not fall
# back to a top-level class: String, StandardError and Comparable hold no
# constants of their own, so String::Foo raises NameError though Foo is
# defined at the top level (the same rule as Holder::Foo for a class of the
# program, #10577). Object::Foo is the top-level one, and a member the
# program puts into the builtin keeps its meaning: a constant written in its
# body or through a path, one a mixed-in module holds, a nested class.
class Foo
  def self.v = 9
end
class Bar
  def self.v = 2
end
class Baz
  def self.v = 3
end
class Qux
  def self.v = 4
end

Pt = Struct.new(:x)
Dt = Data.define(:a)

def try
  p yield
rescue NameError => e
  puts "NameError: #{e.message}"
end

try { String::Foo.v }
try { StandardError::Foo.v }
try { Comparable::Foo.v }
try { Kernel::Foo.v }
try { Hash::Foo.new }
try { String::Pt.new(1).x }
try { StandardError::Dt.new(a: 2).a }
try { Pt.new(3).x }
try { ::String::Foo.v }
try { x = String::Foo; x }
try { defined?(String::Foo) }
try { defined?(StandardError::Foo) }
try { defined?(Comparable::Foo) }
try { Object::Foo.v }
try { ::Foo.v }
try { defined?(Object::Foo) }

# a member written into the builtin, in a body, through a path, or through
# a mixed-in module
class String
  Bar = ::Bar
  class Inner
    def self.v = 6
  end
end
Comparable::Baz = ::Baz
module Holds
  Qux = ::Qux
end
class StandardError
  include Holds
end
module Comparable
  class Deep
    def self.v = 7
  end
end
class StandardError::Wrapped
  def self.v = 8
end

try { String::Bar.v }
try { Comparable::Baz.v }
try { StandardError::Qux.v }
try { String::Inner.v }
try { Comparable::Deep.v }
try { StandardError::Wrapped.v }
try { defined?(String::Bar) }
try { defined?(Comparable::Baz) }

# a member a builtin's ancestor holds is the descendant's too: Exception's
# for StandardError and ArgumentError, Comparable's for String and Integer,
# Numeric's for Integer, Enumerable's for Array, a module mixed into
# StandardError, and a class written into Comparable by a path (all beside a
# top-level class of the same name, so the names resolve by defined?, and the
# path-written one by value)
class Anc1; def self.v = 1; end
class Anc2; def self.v = 2; end
class Anc3; def self.v = 3; end
class Anc4; def self.v = 4; end
class Anc5; def self.v = 5; end
class Anc6; def self.v = 6; end
class Exception
  class Anc1
    def self.v = 11
  end
end
module Comparable
  Anc2 = 22
end
module Mixed
  class Anc3
    def self.v = 33
  end
end
class StandardError
  include Mixed
end
module Enumerable
  class Anc4
    def self.v = 44
  end
end
class Numeric
  Anc5 = 55
end
Comparable::Anc6 = ::Anc6

try { String::Anc6.v }
try { Float::Anc6.v }
try { defined?(ArgumentError::Anc1) }
try { defined?(String::Anc2) }
try { defined?(ArgumentError::Anc3) }
try { defined?(Array::Anc4) }
try { defined?(Integer::Anc5) }
try { defined?(String::Anc6) }
try { defined?(String::Anc7) }

# a constant that aliases a class, written in a builtin, in an ancestor
# (Exception, Numeric, Comparable, Enumerable, Kernel, BasicObject), in a
# module mixed in or prepended; read by the name it was written with
class Al1; def self.v = 61; end
class Al2; def self.v = 62; end
class Al3; def self.v = 63; end
class Al4; def self.v = 64; end
class Al5; def self.v = 65; end
class Al6; def self.v = 66; end
class String
  SA = Al1
end
class Exception
  EA = Al2
end
module Kernel
  KA = Al3
end
class BasicObject
  BA = ::Al4
end
module Pre
  PA = ::Al5
end
class StandardError
  prepend Pre
end
module Inc
  IA = ::Al6
end
module Comparable
  include Inc
end

try { String::SA.v }
try { ArgumentError::EA.v }
try { Symbol::KA.v }
try { Array::BA.v }
try { ArgumentError::PA.v }
try { Integer::IA.v }
try { defined?(String::SA) }
try { defined?(Integer::IA) }

# a mixin recorded after the first use of a builtin path: Data and Struct
# classes written into a module that StandardError includes
Dp = Data.define(:a, :b)
module Holds
  Dp = ::Dp
end
class StandardError
  include Holds
end
try { StandardError::Dp.new(1, 2).a }
try { ArgumentError::Dp.new(a: 3, b: 4).b }
try { StandardError::Dp.new(5, 6) }

# a mixin the class table does not record: an include from a class method
# and from a `class << self` method, run before the read; the module's names
# are given to the builtin
class Bx1; def self.v = 71; end
class Bx2; def self.v = 72; end
class Bx4; def self.v = 74; end
module Mi1; MA1 = Bx1; end
module Mi2; Bx2 = ::Bx2; end
module Mi4; MA4 = Bx4; end
class String
  def self.mix = include(Mi1)
end
class StandardError
  def self.mix = include(Mi2)
end
class Hash
  class << self
    def mix = include(Mi4)
  end
end
String.mix
StandardError.mix
Hash.mix

try { String::MA1.v }
try { ArgumentError::Bx2.v }
try { Hash::MA4.v }

# a class alias that no scope on the path holds: the NameError names the path
# as written, not the class the alias stands for (also for a class of the
# program as the scope)
class Bx9; def self.v = 79; end
Al9 = Bx9
module Mi9; MA9 = Bx9; end
try { String::Al9.v }
try { Comparable::MA9.v }
try { StandardError::Al9.new }
class Hd9; end
try { Hd9::Al9.v }
try { Hd9::MA9.v }
