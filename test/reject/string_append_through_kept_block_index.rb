# A block's parameter handed to the method's own &block as `b[u]` beside a
# `yield`, which keeps the block out of line: `b[u]` calls the proc, which
# appends to the String it is handed, and a block's parameter cannot be
# pulled into the shared handle yet, so the call would hand it a copy and
# the append would not reach `s` (CRuby prints "a!"). Refused at compile
# time until it can be shared (#6179).
# spinel: reject-share
def run(x) = yield(x)
def r2(x, &b)
  return yield(x) if x.size > 50
  run(x) { |u| b[u] }
end
s = +"a"
r2(s) { |w| w << "!" }
p s
