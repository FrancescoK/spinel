# select is also Enumerable#select, Array#select and Kernel#select: the builtin's
# rows hold what each calls back (each, to_io), not only IO.select's.
# select over an Enumerable and an Array through one parameter
class Coll
  include Enumerable
  def initialize(*a) = @a = a
  def each
    @a.each { |x| yield x }
    self
  end
end
def pick(c) = c.select { |x| x > 1 }
p pick(Coll.new(1, 2, 3))
p pick([0, 5])
x = [Coll.new(4, 1), [7]].first
p x.select { |v| v > 2 }
