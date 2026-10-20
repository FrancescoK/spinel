# Array#fill(value, range) on a receiver that may not be an Array, with a
# Range whose ends are only known at run time, so the Range arrives boxed.
class Tape
  def fill(*) = :tape
end

def bytes = ARGV.empty? ? [1, 2, 3, 4] : Tape.new
def num(n) = ARGV.empty? ? n : n.to_f

p bytes.fill(0, num(1)..num(2))
p bytes.fill(0, num(1)...num(3))
p bytes.fill(0, num(2)..num(5))
p bytes.fill(0, num(1)..num(-2))
p bytes.fill(0, num(-3)...num(-1))
p bytes.fill(0, num(2)..)
p bytes.fill(0, ..num(1))
p bytes.fill(0, num(3)..num(1))
p bytes.fill(0, ARGV.empty? ? 2 : nil)
