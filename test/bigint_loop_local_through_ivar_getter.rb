# A loop local promoted to a Bignum, stored in an ivar and read back through
# a getter: the getter returns the Bignum. Its return was derived as an
# Integer before the ivar widened, and the C returned an sp_Bigint * through
# an sp_int.
class Cell
  def set(v) = (@v = v; self)
  def get = @v
end
class Small
  def initialize(n) = @n = n
  def get = @n
end

a = 0
b = 1
i = 0
while i < 200
  c = a + b
  a = b
  b = c
  i += 1
end
cell = Cell.new.set(a)
puts cell.get
p cell.get + 1, cell.get.class
p Small.new(3).get + 1
