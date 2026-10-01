# instance_variable_set(:@a, v) widens an Array ivar the way `@a = v` does:
# an Integer array slot handed a poly array (`@a + [nil]`) becomes the
# general Array, not a boxed scalar. Boxed, the slot lost the Array methods
# that only the Array emitters serve (repeated_permutation with a block
# raised NoMethodError), and map! over it bound its block parameter as an
# Integer, which did not compile. A typed array set into a general Array
# slot is converted, as the plain write converts it.
class N
  def initialize = (@a = [3, 1])
  def run(z)
    @a.collect! { |q| q }
    @a.insert(@a.size + 2, 9) if z.nil?
    instance_variable_set(:@a, @a + [nil]) if z.nil?
    p @a
  end
end
N.new.run(5)
N.new.run(nil)

class P
  def initialize = (@a = [3, 1])
  def run
    c = @a.repeated_permutation(1) { |q| q }
    p c
    instance_variable_set(:@a, @a + [nil])
    p @a, @a[2]
  end
end
P.new.run

class Q
  def initialize = (@a = [3, 1])
  def run
    instance_variable_set(:@a, [nil, 2.5])
    @a.map! { |q| q }
    @a.push(9)
    p @a
  end
end
Q.new.run

# a typed array into a general Array slot, plain and through the frozen check
class R
  def initialize = (@a = [1, nil])
  def run
    instance_variable_set(:@a, [5])
    p @a
  end
end
R.new.run

class S
  def initialize = (@a = ["a"])
  def run
    freeze if @a.size > 4
    instance_variable_set(:@a, [1])
    @a.map! { |q| q }
    @a.push(nil)
    p @a
  end
end
S.new.run
