# A user method or a builtin called on an element of an Array whose
# elements are pointers -- objects, Strings, Arrays -- that the program
# stores nil into or leaves a gap in raises CRuby's NoMethodError for nil.
# The NULL element ran as the method's self and crashed: a block parameter
# an iteration binds, an element read, a value either flows into (a local,
# a parameter), through a local, an ivar, a parameter or a method's value.

class K
  def initialize(v); @v = v; end
  def v; @v; end
end

def val(k) = k.v
def vals(arr) = arr.map { |q| q.v }
def gaps
  z = [K.new(1)]
  z[3] = K.new(2)
  z
end

class Box
  def initialize; @items = []; end
  def put(i, k); @items[i] = k; end
  def total; @items.sum { |k| k.v }; end
end

# a gap a write past the end leaves: a literal index, a computed one,
# insert and fill past the end
a = []
a[3] = K.new(5)
n = 2
b = [K.new(1)]
b[n] = K.new(2)
c = [K.new(1)]
c.insert(3, K.new(4))
d = [K.new(1)]
d.fill(K.new(7), 2, 1)
# a nil pushed, and a copy of an Array that holds one
e = [K.new(1)]
e << nil
f = e + [K.new(2)]
bx = Box.new
bx.put(1, K.new(3))
# Strings and Arrays as elements
s = ["x"]
s[2] = "y"
r = [[1]]
r[2] = [3]
# an Array that holds no nil runs as before
g = [K.new(1), K.new(2)]

begin
  p a.map { |q| q.v }
rescue NoMethodError => ex
  puts "map: #{ex.message}"
end

begin
  p a.each_with_index.map { |q, i| q.v + i }
rescue NoMethodError => ex
  puts "each_with_index: #{ex.message}"
end

begin
  p a.select { |q| q.v > 1 }
rescue NoMethodError => ex
  puts "select: #{ex.message}"
end

begin
  p a.find { |q| q.v == 5 }
rescue NoMethodError => ex
  puts "find: #{ex.message}"
end

begin
  p a.inject(0) { |s, q| s + q.v }
rescue NoMethodError => ex
  puts "inject: #{ex.message}"
end

begin
  p a.sort { |x, y| x.v <=> y.v }
rescue NoMethodError => ex
  puts "sort: #{ex.message}"
end

begin
  p a[1].v
rescue NoMethodError => ex
  puts "index read: #{ex.message}"
end

begin
  p a.first.v
rescue NoMethodError => ex
  puts "first: #{ex.message}"
end

begin
  p (x = a[0]; x.v)
rescue NoMethodError => ex
  puts "local: #{ex.message}"
end

begin
  p a.map { |q| q ? q.v : 0 }
rescue NoMethodError => ex
  puts "guarded: #{ex.message}"
end

begin
  p a.compact.map { |q| q.v }
rescue NoMethodError => ex
  puts "compact: #{ex.message}"
end

begin
  p b.map { |q| q.v }
rescue NoMethodError => ex
  puts "computed index: #{ex.message}"
end

begin
  p c.sum { |q| q.v }
rescue NoMethodError => ex
  puts "insert: #{ex.message}"
end

begin
  p d.count { |q| q.v > 0 }
rescue NoMethodError => ex
  puts "fill: #{ex.message}"
end

begin
  p e.map { |q| q.v }
rescue NoMethodError => ex
  puts "push nil: #{ex.message}"
end

begin
  p f.each { |q| q.v }
rescue NoMethodError => ex
  puts "plus: #{ex.message}"
end

begin
  p val(a[2])
rescue NoMethodError => ex
  puts "param: #{ex.message}"
end

begin
  p vals(b)
rescue NoMethodError => ex
  puts "array param: #{ex.message}"
end

begin
  p gaps.map { |q| q.v }
rescue NoMethodError => ex
  puts "method value: #{ex.message}"
end

begin
  p bx.total
rescue NoMethodError => ex
  puts "ivar: #{ex.message}"
end

begin
  p s.map { |w| w.upcase }
rescue NoMethodError => ex
  puts "strings: #{ex.message}"
end

# a String element read: the String method's own nil test (length), or,
# where the call takes no such path (an enumerator), the element's
begin
  p s[1].length
rescue NoMethodError => ex
  puts "string read: #{ex.message}"
end

begin
  p s[1].each_char.to_a
rescue NoMethodError => ex
  puts "each_char: #{ex.message}"
end

begin
  p s[1].each_byte.to_a
rescue NoMethodError => ex
  puts "each_byte: #{ex.message}"
end

begin
  p s[1].each_line.to_a
rescue NoMethodError => ex
  puts "each_line: #{ex.message}"
end

begin
  p r.map { |w| w.size }
rescue NoMethodError => ex
  puts "arrays: #{ex.message}"
end

begin
  p g.map { |q| q.v }
rescue NoMethodError => ex
  puts "no nil: #{ex.message}"
end
