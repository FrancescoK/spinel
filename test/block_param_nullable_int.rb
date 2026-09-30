# A block parameter a site may leave without a value -- `yield(*xs)` of an
# array only the run time knows the length of, a gathered splat, a
# `b.call(*xs)`, instance_exec with a splat -- is nil when the value is
# missing. When every value it can take is an Integer it stays an Integer
# slot holding the nil sentinel, so each read of it has to answer for nil:
# inspect, interpolation, nil?, a comparison, arithmetic raising the error
# CRuby raises, a boxed container, a Hash key, a case arm, a lambda
# capturing it. A full-length array binds the numbers as before, and a block
# its method also keeps can still be called with anything.

def spread(xs) = yield(*xs)
def gather(xs) = yield(*xs, 5)

spread([1]) do |a, b|
  p a, b
  p b.nil?, b.inspect, b == nil, b.to_i
  puts "b=#{b}."
  p [a, b]
  puts(b ? "truthy" : "falsy")
  begin; b + 1; rescue NoMethodError => e; puts e.message; end
  begin; 1 + b; rescue TypeError => e; puts e.message; end
  begin; b > 0; rescue NoMethodError => e; puts e.message; end
  begin; 1 < b; rescue ArgumentError => e; puts e.message; end
  xs = [a]
  xs << b
  p xs
  p b.is_a?(Integer), b.is_a?(NilClass)
  p({ b => 1 })
  h = { a => :x, b => :y }
  p h, h[nil]
  case b
  when nil then puts "nil arm"
  else puts "else arm"
  end
  case b
  when Integer then puts "Integer arm"
  else puts "not Integer"
  end
  p Integer === b, NilClass === b
end
spread([2]) { |a, b| l = -> { b }; p l.call }
spread([2]) { |a, b| b ||= 7; p [a, b] }
spread([2]) { |a, b| b = a + 1; p b * 2 }
spread([]) { |a, b| p [a, b] }
spread([3, 4]) { |a, b| p a * b }

# a splat gathered with a value after it
gather([]) { |a, b| p [a, b] }
gather([1]) { |a, b| p [a, b] }

# numbered parameters and `it`
spread([6]) { p [_1, _2] }
spread([]) { p it }
spread([8]) { p it + 1 }

# instance_exec with a splat, directly and through a trampoline; a
# trampoline that passes fewer values than the block takes
class Box
  def initialize(v) = @v = v
  def all(*a, &b) = instance_exec(*a, &b)
  def one(x, &b) = instance_exec(x, &b)
end
Box.new(0)
o = Box.new(9)
short = [1]
o.instance_exec(*short) { |a, b| p [a, b, b.nil?, @v] }
o.instance_exec(*[1, 2]) { |a, b| p [a, b] }
o.all(*short) { |a, b| p [a, b, b.nil?, @v] }
o.one(4) { |a, b| p [a, b, b.nil?, @v] }

# a block called through its &block, and one a recursive yielder takes as
# a proc
def call_it(xs, &b) = b.call(*xs)
call_it([3]) { |a, b| p [a, b, b.nil?] }
call_it([3, 4]) { |a, b| p a + b }

def walk(n, xs, &b)
  return yield(*xs) if n <= 0
  walk(n - 1, xs) { |x, y| yield x, y }
end
walk(2, [5]) { |a, b| p [a, b, b.nil?] }
walk(1, [5, 6]) { |a, b| p a * b }

# the array typed only a round after the yielding method
def later(n) = [n]
def chain(n) = spread(later(n)) { |a, b| p [a, b] }
chain(3)

# a block its method also keeps
def kept(xs, &b) = ($keep = b; yield(*xs))
kept([1]) { |a, b| p [a, b] }
$keep.call("s")
