# A boxed array passed to a parameter a --rbs seed pins to Array[Float] is
# converted at the call into a NEW Float array. The constructor allocates the
# object before it stores the argument, so the caller roots the converted
# array across the call: unrooted, a collection inside sp_<C>_new freed it and
# the object kept a dangling @col (the total came out wrong, or the run
# crashed in sp_FloatArray_get).
# spinel: rbs-seed-check
class ConvArgHolder
  attr_reader :col
  def initialize(col, other)
    @col = col
    @other = other
  end
end

def conv_arg_build(n)
  acc = Array.new(n) { |i| i < 0 ? "s" : 0.5 }   # boxed: a PolyArray of Floats
  ConvArgHolder.new(acc, Array.new(n, 0.0))
end

total = 0.0
k = 0
while k < 20
  h = conv_arg_build(200 + k)
  junk = Array.new(500, 1.0)   # allocation pressure between builds
  c = h.col
  total += c[0] + c[c.length - 1] + junk[0]
  k += 1
end
puts total
