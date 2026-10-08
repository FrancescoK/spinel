# A String passed by keyword to a proc, a lambda, a kept block or a Method
# is the caller's String in CRuby, as one passed by position is. Spinel
# shared it by position only (#6179): a keyword travelled as a copy inside
# the call's Hash, and so did one an inlined `yield(k: s)` or `blk.call(k:
# s)` bound to a block's keyword, so the target's append was lost. Each
# probe appends LONG, which always reallocates.
# spinel: gc-minor
LONG = "!" * 100

def seen(s) = [s[0], s.size]

# a proc and a lambda, called every way, beside a positional and another
# keyword, with a default, and through a local holding either
pr = proc { |k1:| k1 << LONG }
s = +"a"; pr.call(k1: s); p seen(s)
s = +"b"; pr.(k1: s); p seen(s)
s = +"c"; pr[k1: s]; p seen(s)
s = +"d"; pr.yield(k1: s); p seen(s)
la = ->(x, k1:, k2: 0) { k1 << LONG; x + k2 }
s = +"e"; p la.call(1, k1: s, k2: 2), seen(s)
two = ->(k1:, k2:) { k2 << LONG; k1.size }
s = +"f"; t = +"g"; p two.call(k2: t, k1: s), seen(s), seen(t)
op = ->(k1: +"") { k1 << LONG }
s = +"h"; op.call(k1: s); p seen(s)
any = ARGV.empty? ? pr : la
s = +"i"; any.call(k1: s); p seen(s)

# a block kept as &blk and called later, and one called inside the method
# (a String yielded to a block is a variable of its own: one also shared
# with a proc is the handle, which an inlined yield cannot lend yet)
def keep(&b) = (@kb = b)
keep { |k1:, **rest| k1 << LONG }
s = +"j"; @kb.call(k1: s, z: 1); p seen(s)
def run(v, &b) = b.call(k1: v)
w1 = +"k"; run(w1) { |k1:| k1 << LONG }; p seen(w1)

# a Method, and its to_proc; the method is called directly as well
def grow(k1:) = (k1 << LONG; nil)
s = +"l"; method(:grow).call(k1: s); p seen(s)
s = +"m"; method(:grow).to_proc.call(k1: s); p seen(s)
s = +"n"; grow(k1: s); p seen(s)

# an inlined yield of a keyword
def yk(v) = yield(k1: v)
w2 = +"o"; yk(w2) { |k1:| k1 << LONG }; p seen(w2)
w3 = +"p"; yk(w3) { |k1:| k1.upcase! }; p w3

# a target that only reads keeps the caller's String as it was; a String a
# lambda captures; the bytes survive
rd = ->(k1:) { k1.size }
s = +"q"; p rd.call(k1: s), seen(s)
s = +"r"; cap = -> { s.size }; pr.call(k1: s); p cap.call
s = +"s\0t"; pr.call(k1: s); p s.bytesize
