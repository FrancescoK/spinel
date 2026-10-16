# A boxed receiver's call of a name a class of the program defines (its
# own or a module's), a container's, or one that answers its receiver
# (to_s, itself, force_encoding) answers a String another name holds: kept
# beside a String changed through another name, a change through it shows
# through that name too.
$all = []
buf = +"buf"
$all << buf
buf << "!"

# a program class's tr answers the String it keeps
class K
  def initialize(s) = @s = s
  def tr(a, b) = @s
  def s = @s
end
k = K.new(+"kept")
kx = ARGV.size > 0 ? +"a-b" : k
ky = kx.tr("-", "_")
$all << ky
ky << "?"
p k.s, ky

# so does a module's, included in a class
$g = +"global"
module Squeeze
  def squeeze = $g
end
class Holder
  include Squeeze
end
hx = ARGV.size > 0 ? +"aab" : Holder.new
hy = hx.squeeze
$all << hy
hy << "?"
p $g, hy

# to_s, itself and force_encoding answer the receiver; first an element
o = +"orig"
ox = ARGV.size > 0 ? 1 : o
t = ox.to_s
$all << t
t << "?"
i = ox.itself
i << "#"
fe = ox.force_encoding("UTF-8")
fe << "%"
e = +"el"
ax = ARGV.size > 0 ? +"ab" : [e]
f = ax.first
$all << f
f << "?"
p o, t, e
p $all
