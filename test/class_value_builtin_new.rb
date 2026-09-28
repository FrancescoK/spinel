# `new` on a class value that holds one of several builtin classes
# constructs that class instead of answering nil.

def b(n); m = String; m = Array if n == 2; m.new.inspect; end
puts b(1), b(2)

def c(n); m = Hash; m = Object if n == 2; m.new.class; end
p c(1), c(2)

def e(n); m = Array; m = String if n == 2; m == Array ? m.new(3) : m.new("x"); end
p e(1), e(2)

def f(n); m = Hash; m = Array if n == 2; m.new(0); end
p f(1)[:missing]

class Foo; def inspect; "Foo!"; end; end
def g(n); m = String; m = Foo if n == 2; m.new; end
p g(1), g(2)

def h(i); [String, Array][i].new; end
p h(0), h(1)

def l(n); m = String; m = Array if n == 2; m.new.class; end
p l(1), l(2)

def q(n); m = Hash; m = Array if n == 2; m.new(2) { _1 * 10 }; end
p q(2)

def hb(n); m = Hash; m = Array if n == 2; m.new { |hh, k| hh[k] = k.to_s * 2 }; end
hh = hb(1)
p hh[:ab], hh

def av(n); m = Array; m = Hash if n == 2; m.new(2, "z"); end
p av(1)

def ac(n); m = Array; m = String if n == 2; m.new([1, 2]); end
p ac(1)

class Pt; def initialize; @v = 1; end; attr_reader :v; end
def up(n); m = Pt; m = Array if n == 2; m.new; end
p up(1).v, up(2)

@k = String
@k = Hash if ARGV.size > 5
p @k.new

$g = Array
$g = String if ARGV.size > 5
p $g.new(1)

tbl = { s: String, a: Array, h: Hash }
p tbl[:s].new("q"), tbl[:a].new(2, 0), tbl[:h].new(7)[:z]

def st(n); m = String; m = Array if n == 2; s = m.new("ab"); s << "c"; s; end
p st(1)

def ex(n); m = RuntimeError; m = ArgumentError if n == 2; m.new("x"); end
p ex(1), ex(2)

def ez(n); m = RuntimeError; m = ArgumentError if n == 2; m.new; end
p ez(1), ez(2)

begin
  [String, Array][1].new(-1)
rescue ArgumentError => err
  p err.message
end
begin
  [String, Array][0].new(1)
rescue TypeError => err
  p err.message
end
begin
  [Object, Array][0].new(1)
rescue ArgumentError => err
  p err.message
end
begin
  [Integer, Array][0].new
rescue NoMethodError => err
  p err.class
end

def sa(n, args); m = String; m = Array if n == 2; m.new(*args); end
p sa(1, []), sa(1, ["x"]), sa(2, [2, 0]), sa(2, [])
def sb(i, args); [Hash, RuntimeError][i].new(*args); end
p sb(0, [5])[:q], sb(1, ["boom"])
class Bx; def initialize(x); @x = x; end; attr_reader :x; end
def sc(n, args); m = Bx; m = Array if n == 2; m.new(*args); end
p sc(1, [3]).x, sc(2, [1])
