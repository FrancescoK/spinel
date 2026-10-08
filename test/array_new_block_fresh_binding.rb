# Every run of an `Array.new(n) { |i| ... }` block binds its index and its
# locals afresh, as any other iterator's block does. A block handed from
# there to a `&b` parameter and kept (in an ivar, a global array, returned)
# must read the index of the element it was built for, and a local the
# block assigned must not carry into the next element. The generator used
# to leave the index in one frame-wide cell it never wrote, so every kept
# block answered 0 and a captured local its last value.
# spinel: gc-minor
def keep(&b) = b

class Holder
  def initialize(&b) = (@b = b)
  def v = @b.call
end

p Array.new(3) { |i| Holder.new { i } }.map(&:v)
p Array.new(3) { |i| keep { i + 1 } }.map(&:call)
$reg = []
def reg(&b) = ($reg << b; nil)
Array.new(3) { |i| reg { i * 2 } }
p $reg.map(&:call)

# a captured local, of a scalar, a String and an Array
p Array.new(3) { |i| j = i; keep { j + 1 } }.map(&:call)
p Array.new(3) { |i| s = "a" * (i + 1); keep { s } }.map(&:call)
p Array.new(3) { |i| a = [i]; keep { a } }.map(&:call)
p Array.new(3) { |i| fl = i * 1.5; -> { fl } }.map(&:call)

# the do form, nested generators, an ivar and a method's return
p (Array.new(2) do |i| keep { -i } end).map(&:call)
p Array.new(2) { |i| Array.new(2) { |j| keep { [i, j] } } }.flatten.map(&:call)

class Table
  def initialize = (@cells = Array.new(3) { |i| grab { i * 10 } })
  def grab(&b) = b
  def values = @cells.map(&:call)
end
p Table.new.values
def gen = Array.new(3) { |i| keep { i * 3 } }
p gen.map(&:call)

# inside a lambda's body, a captured local
f = -> { Array.new(3) { |i| t = i; keep { t } } }
p f.call.map(&:call)

# an uncaptured local is fresh too
p Array.new(3) { |i| x ||= i * 10; x }
p Array.new(3) { |i| y = "s" if i == 0; y.inspect }
