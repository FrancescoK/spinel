# A Range passed to `[]` on a value from anywhere (a computed send's)
# reaches every user `[]` at compile time; Regs#[] still reads an Integer
# element.
class Regs
  def initialize = @values = Array.new(8, 3)
  def [](reg) = @values[reg]
end

class Loader
  def initialize(name) = @name = name
  def load = send(@name)
  def payload = "abcdef"
end

data = Loader.new(:payload).load
p data[2..]
r = Regs.new
p r[1] + 1
