# product(other) with a block on a general (poly) Array: each pair goes to
# the block and the call answers the receiver. Only the typed arrays had a
# one-argument block form; a poly receiver raised NoMethodError naming
# Array, so an ivar Array that once held nil could not run it.
a = [3, "x"]
r = a.product([7]) { |q| p q }
p r.equal?(a)
a.product([[1, 2]]) { |q| p q }
a.product([]) { |q| p q }
n = 0
a.product(["s", 2.5]) { |q| n += q.size }
p n

b = [3, 1]
b = 5 if ARGV.size > 3
p(b.product([7]) { |q| p q })

c = [3.5, nil]
c.product([7.5]) { |q| q }
p c

class N
  def initialize = (@a = [3, 1, 2])
  def run(z)
    @a.product([7]) { |q| q }
    @a.push(nil) if z.nil?
    p @a.product([0]) { |q| q }
  end
end
N.new.run(1)
N.new.run(nil)
