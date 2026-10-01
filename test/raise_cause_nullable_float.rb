# A `cause:` typed Float that may hold nil is no cause when it is nil, and
# a TypeError only when it holds a Float.
def emit(cause = nil)
  raise "x", cause: cause
rescue => e
  p [e.class, e.message, e.cause]
end
emit(1.5)
emit

def pick(k) = k > 0 ? 2.5 : nil

def emit2(k)
  raise ArgumentError, "a", cause: pick(k)
rescue => e
  p [e.class, e.message, e.cause]
end
emit2(1)
emit2(0)

f = 3.5
begin
  raise "y", cause: f
rescue => e
  p [e.class, e.message, e.cause]
end
