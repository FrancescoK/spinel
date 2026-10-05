# A container that stores an element of itself (`@m[to] = @m[from]`), read
# back into a poly local that a String mutator runs on. Demanding the
# container's Strings into handles walked its stores, met the same element
# read among them, and walked them again, until the compiler's stack ran out.

class Slots
  def initialize
    @m = {}
    @m[0] = "ab".dup
    @m[1] = [1, 2]
  end

  def copy(to, from)
    @m[to] = @m[from]
  end

  def app(i)
    x = @m[i]
    x << "z"
    x
  end
end

f = Slots.new
f.copy(2, 0)
p f.app(2)
p f.app(0)

# the same through two containers that store each other's elements
class Pair
  def initialize
    @a = ["p".dup, :s]
    @b = ["q".dup, :t]
  end

  def cross
    @a[1] = @b[0]
    @b[1] = @a[0]
  end

  def app(k)
    x = k == 0 ? @a[1] : @b[1]
    x << "!"
    x
  end
end

pr = Pair.new
pr.cross
p pr.app(0), pr.app(1)
