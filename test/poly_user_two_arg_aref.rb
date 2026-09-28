# A user-defined two-argument [] is called on a receiver of more than one
# class, as the one- and three-argument forms are, where it answered nil;
# a String, Array or Proc beside it still slices or is called.
class Grid
  def [](x, y)
    x + y
  end
end

def lookup(object)
  object[1, 2]
end

p lookup(Grid.new)
p lookup([10, 20, 30])
p lookup("hello")
p lookup(->(a, b) { a * 10 + b })

class Named
  def [](a, b) = "#{a}-#{b}"
end
[Named.new, %w[a b c d]].each { |o| p o[1, 2] }

# operands that are not both Integers
def pick(o, k, n) = o[k, n]
p pick(Named.new, :x, "y")
p pick("abcdef", 2, 3)
