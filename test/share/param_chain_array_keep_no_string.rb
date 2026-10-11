# --share-strings: an accumulator Array handed down a chain of methods
# (ffi's `keep`, six deep) is an Array at every call, so its `<<` is no
# String's mutation. Read as one it had been, the Strings of an unrelated
# Hash became shared handles and the program was refused (#8500, #8501).
class Store
  def initialize = (@aliases = {})
  def alias(a, b) = @aliases[a] = b
  def lookup(a) = @aliases[a]
end

def w6(addr, v, keep) = (keep << v if keep; addr + 1)
def w5(addr, v, keep) = w6(addr, v, keep)
def w4(addr, v, keep) = w5(addr, v.to_s, keep)
def w3(addr, v, keep) = w4(addr, v, keep)
def w2(addr, v, keep) = w3(addr, v, keep)
def w1(addr, v, keep) = w2(addr, v, keep)

kept = []
p w1(0, "a", kept)
p w1(1, "b", nil)
p w1(2, 3, kept)
p kept

s = Store.new
s.alias("mysize", "size_t")
p s.lookup("mysize")
p s.lookup("mysize").frozen?
