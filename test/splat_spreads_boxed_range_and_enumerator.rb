# A splat spreads a Range's members and the items an Enumerator yields, as
# their to_a does. Where the value's kind is known only at run time -- a
# parameter other calls give an Array or a String, an element read out of a
# container -- or is an Enumerator, it went in as the one element:
# `c.push(*a)` with a = 3..4 gave [0, "s", 3..4].
def pushed(v)
  c = [0, "s"]
  c.push(*v)
  c
end
p pushed(3..4), pushed(1...3), pushed("a".."b")
p pushed([1, 2].each_slice(1)), pushed([4, 5].each), pushed([6, 7].map)
p pushed([1, 2]), pushed(nil), pushed(5), pushed("t")
p pushed(1...1), pushed(4..2)

def unshifted(v)
  c = [0]
  c.unshift(*v)
  c
end
p unshifted(3..4), unshifted([8]), unshifted("t")
def inserted(v) = [9, "x"].insert(1, *v)
p inserted(3..4), inserted([8]), inserted("t")
def onto_empty(v) = [].push(*v)
p onto_empty(3..4), onto_empty([8]), onto_empty("t")

# read out of a container
r = [1..2, "s"][0]
a = pushed(r)
a << 9
p a, r

# an Enumerator in a local; one already stepped still gives every item
e = [1, 2, 3].each_slice(2)
c = [0]
c.push(*e)
p c
st = [1, 2, 3].each
st.next
d = []
d.push(*st)
p d, st.next
many = []
many.push(*[1, 2].each_with_index)
many.push(*"ab".each_char)
many.push(*3.times)
many.push(*1.upto(2))
many.push(*{ a: 1 }.each)
many.push(*[5, 6].each_cons(2))
many.push(*1.step(7, 3))
p many

# the arguments of a method, values_at, the value of a break
def rest(*r) = r
def call(v) = rest(1, *v, 2)
p call(3..4), call([8]), call("t"), call(nil)
def at(v) = [10, 11, 12, 13, 14].values_at(*v)
p at(1..2), at([0]), at(4)
def broke(v)
  [10].each { |x| break *v }
end
p broke(3..4), broke([8]), broke("t")

# an endless Range cannot become an Array
begin
  p pushed(1..)
rescue RangeError
  puts "RangeError"
end

class Bag
  def initialize(src) = @src = src
  def all = [0, "s"].push(*@src)
end
p Bag.new(3..4).all, Bag.new([1]).all, Bag.new("t").all, Bag.new([7, 8].each_slice(1)).all
