# A `**` operand typed as an Integer, Float, String, Array or object slot
# that can also hold nil is nil-checked at run time: nil carries no
# keywords, and any other value raises the TypeError. Only a value that
# cannot be nil raises it outright.
class Foo; end

class Slots
  def arr = @arr
  def obj = @obj
  def fill
    @arr = [1]
    @obj = Foo.new
  end
end

def fi(v) = v
def ff(v) = v
def fs(v) = v
def k(a: 0, b: 0) = [a, b]
def kr(a:) = a
def m(**kw) = kw
def both(a: 0, **kw) = [a, kw]
def yk(a: 0) = yield(a)

class Box
  def initialize(a: 0)
    @a = a
  end

  attr_reader :a

  def k(a: 0, b: 0) = [a, b]
end

Point = Data.define(:x, :y)
Opts = Struct.new(:a, :b, keyword_init: true)
Plain = Struct.new(:a, :b)

def try
  p yield
rescue ArgumentError, TypeError => e
  puts "#{e.class}: #{e.message}"
end

fi(1)
ff(1.5)
fs("s")
Slots.new.fill
empty = Slots.new
h = { a: 1 }

# named keywords, nil and not
try { k(**fi(nil)) }
try { k(**ff(nil)) }
try { k(**fs(nil)) }
try { k(**empty.arr) }
try { k(**empty.obj) }
try { k(**fi(2)) }
try { k(**ff(2.5)) }
try { k(**fs("t")) }
try { kr(**fi(nil)) }

# an instance method, .new and an inlined yielding method
try { Box.new.k(**fi(nil)) }
try { Box.new.k(**fs("t")) }
try { Box.new(**fi(nil)).a }
try { Box.new(**fi(6)).a }
try { yk(**fi(nil)) { |a| a } }
try { yk(**fi(7)) { |a| a } }

# a **kw rest, and both
try { m(**fi(nil)) }
try { m(**fs("t")) }
try { both(**ff(nil)) }

# a later operand
try { m(**h, **fi(nil)) }
try { m(**h, **fi(3)) }

# a merged call
try { k(**h, **fi(nil), **{ b: 2 }) }
try { k(a: 5, **fs(nil)) }
try { k(**h, **ff(3.5)) }

# a constructor
try { Point.new(**fi(nil)) }
try { Opts.new(**fs(nil)) }
try { Plain.new(**ff(nil)) }
try { Opts.new(**fi(4)) }

# a key naming no member, beside the operand
try { Opts.new(z: 1, **fi(nil)) }
try { Opts.new(z: 1, **fi(5)) }

# literals are never nil
try { k(**1) }
try { k(**"s") }
