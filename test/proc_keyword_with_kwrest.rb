# A proc or block taking both named keywords and `**rest` binds the rest to
# the keywords the named ones don't take. The mix was refused as an
# "uncaptured outer variable" even when the proc was never called.

pr = proc { |k: 0, **o| [k, o] }
p pr.call(k: 1, z: 2)                      #=> [1, {z: 2}]
p pr.(z: 3)                                #=> [0, {z: 3}]
p pr.call                                  #=> [0, {}]

# The rest is a fresh hash: writing to it leaves the caller's alone.
h = { k: 3, z: 4, w: 5 }
wr = proc { |k: 0, **o| o[:new] = 1; [k, o] }
p wr.call(**h)                             #=> [3, {z: 4, w: 5, new: 1}]
p h                                        #=> {k: 3, z: 4, w: 5}

la = lambda { |a, k: 0, **o| [a, k, o] }
p la.call(1, k: 2)                         #=> [1, 2, {}]
p la.(1, **h)                              #=> [1, 3, {z: 4, w: 5}]

# A block stored in an ivar and called later.
class Holder
  def initialize(&b) = @b = b
  def run(*a, **kw) = @b.call(*a, **kw)
end
hb = Holder.new { |a, k: 0, **o| [a, k, o] }
p hb.run(1, k: 5, z: 2)                    #=> [1, 5, {z: 2}]
p hb.run(1)                                #=> [1, 0, {}]

# A block lifted into a proc by a recursive yielder, forwarding its keywords.
def ry(n, h)
  return yield(n, **h) if n == 0
  ry(n - 1, h) { |a, k: 0, **o| yield a, k: k + 1, **o }
end
ry(2, { k: 1, q: 2 }) { |a, k:, q:| p [a, k, q] }   #=> [0, 3, 2]
