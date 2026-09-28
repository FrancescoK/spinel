# A `**` operand typed as a Hash that holds nil at run time (an unset
# slot's reader, a parameter or local bound from one) carries no keywords,
# as `**nil` does: every keyword takes its default, a required one is
# missing and a **kw rest is empty. A Hash literal is never nil.
class Slots
  def sym = @sym
  def str = @str
  def fill
    @sym = { a: 1 }
    @str = { "b" => 2 }
  end
end

def k(a: 0, b: 0) = [a, b]
def kr(a:) = a
def m(**kw) = kw
def both(a: 0, **kw) = [a, kw]
def yk(a: 0) = yield(a)
def fwd(h) = k(**h)
def rebind(**kw)
  kw = Slots.new.sym
  k(**kw)
end

class Box
  def initialize(a: 0)
    @a = a
  end

  attr_reader :a

  def k(a: 0, b: 0) = [a, b]
end

Opts = Struct.new(:a, :b, keyword_init: true)

def try
  p yield
rescue ArgumentError, TypeError => e
  puts "#{e.class}: #{e.message}"
end

empty = Slots.new
full = Slots.new
full.fill
local = empty.sym

# named keywords, nil and not
try { k(**empty.sym) }
try { k(**empty.str) }
try { k(**full.sym) }
try { kr(**empty.sym) }
try { kr(**full.sym) }

# a parameter, a local and a reassigned **kw bound from the slot
try { fwd(empty.sym) }
try { fwd(full.sym) }
try { k(**local) }
try { rebind(a: 9) }

# an instance method, .new and an inlined yielding method
try { Box.new.k(**empty.sym) }
try { Box.new(**empty.sym).a }
try { Box.new(**full.sym).a }
try { yk(**empty.sym) { |a| a } }
try { yk(**full.sym) { |a| a } }

# a **kw rest, and both
try { m(**empty.sym) }
try { m(**full.sym) }
try { both(**empty.sym) }
try { both(**full.sym) }

# a merged call and a later operand
try { k(b: 2, **empty.sym) }
try { k(**empty.sym, **full.sym) }
try { m(**full.sym, **empty.sym) }

# a Struct constructor
try { Opts.new(**empty.sym) }

# a literal is never nil
try { k(**{ a: 3 }) }
