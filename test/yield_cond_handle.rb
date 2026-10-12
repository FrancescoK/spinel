# A conditional yielded to a block whose arms include a bang's value or the
# receiver itself hands on the receiver's String when that arm runs: the
# block that appends to it changes the receiver, through a ternary, `||` or
# an arm that is a bang, and a frozen receiver raises FrozenError.
def tern(s) = yield(s.upcase! ? s : s)
def bang_arm(s, f) = yield(f ? s.upcase! : nil)
def bang_or(s) = yield(s.upcase! || s)
def plain_or(s, f) = yield(f ? s : nil)

s = +"ab"
tern(s) { |x| x << "!" }
tern(s) { |x| x << "?" }
p s

s = +"ab"
bang_arm(s, true) { |x| x << "!" if x }
bang_arm(s, true) { |x| p x }
bang_arm(s, false) { |x| p x }
p s

s = +"ab"
bang_or(s) { |x| x << "!" }
bang_or(s) { |x| x << "?" }
p s

s = "ab"
begin
  plain_or(s, true) { |x| x << "!" }
rescue => e
  p e.class
end
p s
