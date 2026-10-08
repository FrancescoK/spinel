# A String passed by keyword reaches a proc, a kept block or a method as
# the caller's String wherever one passed by position does (#6469 shared
# the keyword at a proc's and a Method's own call). Through a yield into a
# block the method keeps, a yield into a proc passed with `&`, a proc read
# out of a slot that holds other values, `instance_exec`, and an
# UnboundMethod's `bind_call` or `bind(o).call`, the keyword was refused
# while the position was shared. Each probe appends LONG, which always
# reallocates, and has its own variable.
# spinel: gc-minor
LONG = "!" * 100
def seen(s) = [s[0], s.size]

# a yield into a block the method keeps, and into a proc passed with &
def keep_y(v, &b) = (@kept = b; yield(k: v))
a = +"a"; keep_y(a) { |k:| k << LONG }; p seen(a)
b = +"b"; @kept.call(k: b); p seen(b)
def pass_y(v, &b) = (@other = b; yield(1, k: v))
pr = proc { |n, k:| k << LONG }
c = +"c"; pass_y(c, &pr); p seen(c)
d = +"d"; keep_y(d) { |k:| k.upcase! }; p d

# a proc read out of a slot that holds other values too
lam = ->(k:) { k << LONG }
e = +"e"; [lam, 1][ARGV.size].call(k: e); p seen(e)
f = +"f"; [lam, 1][ARGV.size].(k: f); p seen(f)

# instance_exec on an object
class Box
  def fill(k:) = (k << LONG; nil)
end
g = +"g"; Box.new.instance_exec(k: g) { |k:| k << LONG }; p seen(g)

# an UnboundMethod, bound with bind_call and with bind
h = +"h"; Box.instance_method(:fill).bind_call(Box.new, k: h); p seen(h)
i = +"i"; Box.instance_method(:fill).bind(Box.new).call(k: i); p seen(i)
um = Box.instance_method(:fill)
j = +"j"; um.bind_call(Box.new, k: j); p seen(j)
l = +"l"; Box.new.fill(k: l); p seen(l)

# a target that only reads keeps the String; the bytes survive
rd = ->(k:) { k.size }
m = +"m"; p [rd, 1][ARGV.size].call(k: m), seen(m)
n = +"n\0o"; [lam, 1][ARGV.size].call(k: n); p n.bytesize
