# force_encoding evaluates its argument before it looks at the receiver, as
# any method call does: a frozen or nil receiver raises after the argument
# ran. And a fresh receiver stays alive while an argument that allocates and
# collects is computed.

$log = []
def enc(e)
  $log << e.to_s
  e
end

s = "x".freeze
begin
  s.force_encoding(enc(Encoding::BINARY))
rescue FrozenError => ex
  p ex.class
end

# a shared handle (#6179), frozen
pr = proc { |t| t << "!" }
h = +"abc"
pr.call(h)
h.freeze
begin
  h.force_encoding(enc(Encoding::UTF_8))
rescue FrozenError => ex
  p ex.class
end

# the same handle read back out of a mixed Array
w = [h, 1][0]
begin
  w.force_encoding(enc(Encoding::US_ASCII))
rescue FrozenError => ex
  p ex.class
end

def maybe(f) = f ? nil : +"a"
m = maybe(true)
begin
  m.force_encoding(enc(Encoding::BINARY))
rescue NoMethodError => ex
  p ex.class
end
p $log

# the argument allocates and collects while the receiver is held
def churn(e)
  a = []
  2000.times { |i| a << "pad#{i}" * 4 }
  GC.start
  e
end
r = ("é" * 3).dup.force_encoding(churn(Encoding::BINARY))
p r, r.encoding, r.bytesize
t = +"é"
pr.call(t)
u = [t, 1][0]
u.force_encoding(churn(Encoding::BINARY))
p u, u.encoding
