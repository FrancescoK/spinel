# run-scale: 1000 | 16000 | 1.5
# A receiver that may be nil, tested on every call in a hot loop (the call
# plan's nil target, #7444): the test allocates nothing, so the bytes stay
# flat when the loop runs 16x.
class Cell
  def initialize(v) = @v = v
  def v = @v
end
def pick(n) = n > 0 ? Cell.new(n) : nil
c = pick(ARGV[0].to_i)
t = 0
ARGV[0].to_i.times { |i| t += c.v + i }
p t
