# A `Hash.new { |h, k| ... }` default block runs with a frame of its own: it
# may write locals, read and write the enclosing scope's, run an iteration
# block, and make a block or a lambda that outlives it. The block was
# emitted as a bare C function declaring only the hash and the key, so each
# of these named an identifier it never declared, and a proc made inside it
# had its own function written into the middle of this one: the C build
# failed. Such a block is now a real proc the hash's default calls.
# spinel: gc-minor
def keep(&b) = b

kept = Hash.new { |hh, k| hh[k] = keep { k * 2 } }
p kept[3].call, kept[4].call

body = Hash.new { |hh, k| v = k * 3; hh[k] = v }
p body[2], body

base = 10
outer = Hash.new { |hh, k| k + base }
p outer[5]

count = 0
counted = Hash.new { |hh, k| count += 1; hh[k] = count * 100 }
p counted[:a], counted[:b], counted[:a], count

lam = Hash.new { |hh, k| hh[k] = -> { k.to_s * 2 } }
p lam[:ab].call

iter = Hash.new { |hh, k| hh[k] = (1..k).map { |j| j * k } }
p iter[3]

kept_local = Hash.new { |hh, k| w = "w#{k}"; hh[k] = keep { w } }
p kept_local[1].call, kept_local[2].call

nested = Hash.new { |hh, k| hh[k] = Hash.new { |h2, k2| h2[k2] = [k, k2] } }
p nested[:x][:y], nested

skip = Hash.new { |hh, k| next 0 if k == 0; hh[k] = k * base }
p skip[0], skip[2], skip.default_proc.call(skip, 4), skip

def mk(tag) = Hash.new { |hh, k| hh[k] = "#{tag}-#{k}" }
ma = mk("a")
mb = mk("b")
p ma[1], mb[2], ma.dup[3]

class Scaled
  def initialize(f) = (@f = f; @h = Hash.new { |hh, k| t = k * @f; hh[k] = t })
  def [](k) = @h[k]
end
p Scaled.new(7)[3]

fib = Hash.new { |hh, n| s = n < 2 ? n : hh[n - 1] + hh[n - 2]; hh[n] = s }
p fib[40]
