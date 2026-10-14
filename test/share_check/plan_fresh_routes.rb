# The String plan (#8328) on values repr_of represents as a new handle
# wrapped where one is demanded (RS_FRESH). That is repr_of's answer for a
# handle whose source none of its checks names, not a proof that the
# String is new, so the plan asks the producer's own rules: a call that
# answers its String receiver, a bang on a boxed receiver, a route the
# analysis checks a carry against. It refused each of these, while the C
# handed over the handle, and a change through either name shows through
# the other.

# a call answering its receiver: an append, an iterator with a block
s = +"a"
a = [s, s << "b"]
a[1] << "!"
w = +"w"
held = [w.each_char { }]
held[0] << "4"
p a, w

# a bang on a boxed receiver, its answer the receiver's box
mix = [+"ab ", 1]
r = mix[0].upcase! || mix[0]
r << "?"
p mix, r.equal?(mix[0])

# routes: a value route's block, String(), a lambda's answer, a conditional
# with a handle arm
t = +"n"
ra = [t.then { |x| x }, String(t)]
ra[0] << "!"
src = +"src"
l = ->(k) { k == 0 ? "lit" : src }
la = [l.(1)]
la[0] << "~"
u = +"u"
ca = [0, ARGV.empty? ? (u << "1") : (t << "2")]
ca[1] << "3"
p t, src, u
