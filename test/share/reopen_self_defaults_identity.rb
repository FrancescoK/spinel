# spinel: gc-minor
# Shared-mode defaults and yields retain the actual String receiver.
class String
  def identity_default(b = self) = yield(b)
  def append_default(a = self) = (self << "!"; yield(a))
  def value_default(b = self) = b
  def compare_default(b = self) = self.equal?(b)
  def wrap_default(b = self) = [b]
  def array_default(b = [self]) = b
end
s = +"ab"
p s.identity_default { |v| v }.equal?(s)
p s.identity_default(s) { |v| GC.start; v }.equal?(s)
s = +"q"
t = s.append_default { |v| v }
p [s, t, s.equal?(t)]
s = +"q"
t = s.append_default(s) { |v| GC.start; v }
p [s, t, s.equal?(t)]
s = +"x"
t = s.value_default
t << "!"
p [s, t]
def forwarded_identity(receiver, &) = receiver.identity_default(&)
p forwarded_identity(s) { |v| GC.start; v }.equal?(s)

p s.compare_default
p s.compare_default(s)

s = +"x"
a = s.wrap_default
a[0] << "!"
p [s, a[0], s.equal?(a[0])]
s = +"y"
a = s.array_default
a[0] << "!"
p [s, a[0], s.equal?(a[0])]

def bang(x) = x << "!"
s = +"x"
t = s.value_default
bang(t)
p [s, t]
s = +"x"
[s.value_default].each { |e| e << "!" }
p s
p [+"x"][0].value_default
p [+"x"][0].identity_default { |v| v << "?" }

class String
  def plain_default(b = self) = yield(b)
end
p (+"ab").plain_default { |v| v }
s = +"cd"
p s.plain_default { |v| v << "!" }
p s

# a yielding method spliced in with a literal block answers the String the
# block does, and an identity comparison with it must not make a handle of a
# constant's bytes first
LIT = "ghi"
def yield_it = yield
p(yield_it { LIT }.equal?(LIT))
p(yield_it { LIT.scan(/./) { } }.equal?(LIT))
p(LIT.equal?(yield_it { LIT }))
w = +"jk"
p(yield_it { w }.equal?(w))
p(w.equal?(yield_it { w }))
