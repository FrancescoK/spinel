# keep stores its reader's String (@n itself) into the caller's Array, and
# the caller appends through the element. The element store is walked in
# the caller only, so the element would stay a copy: refused, not compiled
# with "n".
class K
  attr_reader :n
  def initialize = (@n = +"n")
  def keep(a) = (a << n)
end
k = K.new
a = []
k.keep(a)
a[0] << "!"
p k.n
