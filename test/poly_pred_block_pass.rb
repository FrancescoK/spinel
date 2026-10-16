# eql? and equal? with a block on a poly receiver answer as without one:
# the builtin ignores the block, and an override still receives it.
class Picky
  def eql?(other, &b) = b ? b.call(other) : false
  def equal?(other) = block_given? ? yield(other) : :plain
end

def pass_eql(r, a, &b) = r.eql?(a, &b)
def pass_equal(r, a, &b) = r.equal?(a, &b)

xs = [Picky.new, 2, 2.0, "a", :s, nil]
p xs.map { |x| pass_eql(x, 2) }
p xs.map { |x| pass_eql(x, 2) { |o| o * 10 } }
p xs.map { |x| pass_equal(x, 2) }
p xs.map { |x| pass_equal(x, 2) { |o| o + 1 } }
p xs.map { |x| x.eql?(2) { :ignored } }
