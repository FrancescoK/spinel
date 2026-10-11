# A zero-argument IO reader through a value of several classes, one of whose
# readbyte answers nil: the answer holds its nil beside the value, and the
# IO arm's byte goes into it as an Integer.
class Bytes
  def initialize(n) = @n = n
  def readbyte = @n == 0 ? nil : 120
end

def next_byte(io) = io.readbyte

r, w = IO.pipe
w.write("AB")
w.close
[Bytes.new(1), r, r].each { |io| p next_byte(io) }
p next_byte(Bytes.new(0))
