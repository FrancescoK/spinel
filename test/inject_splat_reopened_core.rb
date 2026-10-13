# inject given its arguments through a splat picks the form by their count;
# the count, the reads and the message are the builtins' own, whatever the
# program reopens

class Array
  def length = 0
  def [](i) = :x
end
class Integer
  def ==(o) = false
  def >(o) = false
end
class String
  def +(o) = "plus"
end
def g(a, *s) = a.inject(*s)
p g([1, 2, 3], :+)
p g([1, 2, 3], 10, :+)
p((g([1, 2], 1, 2, 3) rescue $!.message))
