# An Array held by an instance variable, a global, a class variable or a
# constant, and written to a second name, is one Array: a push of another
# element kind through the second name widens it, and the first name sees
# the push. Each name had its own typed slot, and only two locals were
# widened together, so the write between the names converted the Array to
# the general one -- a copy -- and the push landed on the copy. A Hash
# written a key of another kind through the second name is the same.

# ivar to ivar, the push of a String into an Integer Array
@a = [1]
@b = @a
@b << "x"
p @a
p @a.equal?(@b)
def count(arr) = arr.size
p count(@a)

# global to global, global to local, local to global, local to ivar
$a = [1]
$b = $a
$b << "x"
p $a
$c = [2]
d = $c
d << :s
p $c
e = [3]
$f = e
$f << 4.5
p e
g = [+"s"]
@h = g
@h << 9
p g

# a chain of globals and an ivar in between
$i = [1]
@j = $i
$k = @j
$k << nil
p $i

# constants, a chain of them
L = [1]
M = L
N = M
N.push(:a, "b")
p L

# an ivar aliased in one method and pushed in another
class Holder
  def initialize
    @list = [1.5]
    @alias = @list
  end

  def add(x) = @alias << x
  def show = p(@list)
end
h = Holder.new
h.add(2)
h.show

# class variables, aliased in the class body and in a class method
class Counter
  @@a = [1]
  @@b = @@a
  def self.setup
    @@c = [:q]
    @@d = @@c
  end

  def self.add
    @@b << "x"
    @@d << 1
  end

  def self.show
    p @@a
    p @@c
  end
end
Counter.setup
Counter.add
Counter.show

# an element write and an unshift through the alias
@m = [1]
@n = @m
@n.unshift("x")
@n[4] = :z
p @m

# a push of the same kind keeps the Array typed, and shared
@o = [1, 2]
@q = @o
@q << 3
p @o.sum

# a Hash the same way: a key of another kind through a second name
H = {1 => 2}
G = H
G["k"] = :v
p H
$hh = {"a" => 1}
hg = $hh
hg[:z] = 2.5
p $hh
