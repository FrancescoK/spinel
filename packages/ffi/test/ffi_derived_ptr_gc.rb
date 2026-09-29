# A pointer derived from a MemoryPointer (+, slice, an inline struct or array
# field) keeps the buffer alive: collections between the derivation and the
# use leave the bytes it reads intact.
require "ffi"

class In < FFI::Struct
  layout :a, :int32, :b, :int32
end
class Out < FFI::Struct
  layout :tag, :int32, :inner, In, :vals, [:int32, 4]
end

def churn
  i = 0
  junk = nil
  while i < 3000
    junk = "x" * 256
    i += 1
  end
  GC.start
  junk.size
end

def derived
  mp = FFI::MemoryPointer.new(:int32, 64)
  64.times { |i| mp.put_int32(i * 4, i * 11) }
  mp + 40
end

def sliced
  mp = FFI::MemoryPointer.new(:int32, 64)
  64.times { |i| mp.put_int32(i * 4, i * 7) }
  mp.slice(8, 16)
end

def inner
  o = Out.new
  o[:inner][:a] = 123
  o[:inner][:b] = 456
  o[:inner]
end

def vals
  o = Out.new
  4.times { |i| o[:vals][i] = 1000 + i }
  o[:vals]
end

p1 = derived
p2 = sliced
p3 = inner
p4 = vals
churn
churn
p p1.get_int32(0), p1.get_int32(4), (p1 + 8).get_int32(0)
p p2.get_int32(0), p2.get_int32(12)
p p3[:a], p3[:b]
p p4.to_a
