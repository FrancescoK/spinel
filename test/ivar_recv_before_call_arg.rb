# A builtin call on an ivar receiver reads the ivar BEFORE its arguments run,
# as Ruby evaluates a receiver first. `@data[swap(i)]` handed the C call the
# ivar and the argument as two unsequenced operands, so the read could see
# the array `swap` had just put there -- a wrong answer -- and, once `swap`
# had allocated enough to collect, the old array was read after it was freed.
# spinel: gc-minor
class Holder
  def initialize
    @data = [10, 20, 30, 40]
    @str = "abcd"
    @h = { 0 => "zero", 1 => "one" }
  end

  def swap(i)
    @data = [-1, -2, -3, -4]
    @str = "wxyz"
    @h = { 0 => "ZERO", 1 => "ONE" }
    junk = []
    200.times { |k| junk << Array.new(64) { |q| q + k } }
    i
  end

  def index(i) = @data[swap(i)]
  def fetch(i) = @data.fetch(swap(i))
  def byte(i) = @str.getbyte(swap(i))
  def hash_get(i) = @h[swap(i)]
  def reset
    @data = [10, 20, 30, 40]
    @str = "abcd"
    @h = { 0 => "zero", 1 => "one" }
  end
end

h = Holder.new
p h.index(1)
h.reset
p h.fetch(2)
h.reset
p h.byte(3)
h.reset
p h.hash_get(1)

# many rounds, so a read of a collected array shows as a wrong sum
t = 0
500.times do |n|
  h.reset
  t += h.index(n % 4)
end
p t
