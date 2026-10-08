# An ivar's String stored into an Array or Hash whose elements are appended
# to is the ivar's own object: the append shows through the ivar, as it
# does for a local stored the same way. The ivar never took the shared
# handle (#6179) for such a store, and the element was wrapped as a fresh
# handle over a copy of its text, so the append was lost to the ivar.
# spinel: gc-minor
def app(x) = x << "!"

class Holder
  def initialize(v = +"ab") = @s = v
  def lit
    app(@s)
    arr = [@s]
    arr[0] << "A"
    p @s
  end
  def hash
    h = { k: @s }
    h[:k] << "K"
    p @s
  end
  def pushed
    out = []
    out << @s
    out.push(@s)
    out[0] << "P"
    out[1] << "Q"
    p @s, out
  end
  def show = @s
end

h = Holder.new
h.lit
h.hash
h.pushed

# an ivar set from the constructor's argument is the caller's String
s = +"cd"
k = Holder.new(s)
k.lit
p s

# a frozen ivar refuses the append through the container
class Frozen
  def initialize = @s = (+"fr").freeze
  def run
    arr = [@s]
    arr[0] << "x"
  rescue FrozenError => e
    p e.class
  ensure
    p @s
  end
end
Frozen.new.run

# an Integer ivar stored the same way is still an Integer
class Num
  def initialize = @n = 3
  def run
    arr = [@n, 1]
    arr[0] += 1
    p @n, arr
  end
end
Num.new.run
