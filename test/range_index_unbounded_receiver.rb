# A Range passed to `[]` on a receiver of no known class reaches every
# user `[]` at compile time; Regs#[] still reads an Integer element.
class Regs
  def initialize = @values = Array.new(8, 3)
  def [](reg) = @values[reg]
end

r = Regs.new
p r[1] + 1
data = [[1, 2, 3], "abc"].send(:first)
p data[1..]
