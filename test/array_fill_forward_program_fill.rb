# A program that defines its own Array#fill: a block forwarded to it with
# &b reaches that fill, which takes the block as a Proc.

class Array
  def fill(*a, &b) = b ? b.call(5) : :no_block
end

def g(a, &b) = a.fill(&b)
p g([1, 2]) { |i| i + 1 }
p g([1, 2])
