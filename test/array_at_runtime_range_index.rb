# Array#at takes an Integer index and converts it with to_int: an index
# that is a Range, nil or a String only at run time raises TypeError where
# `[]` would slice, on a typed Array and a boxed one, after the receiver and
# the index are read (a Hash still has no #at), and a Float truncates

def r(a) = (puts "recv"; a)
def i(x) = (puts "idx"; x)
def f(a, x) = r(a).at(i(x))
p f([1, 2], 1)
p f([1, 2], 5)
begin; f([1, 2], 0..1); rescue TypeError => e; puts e.message; end
begin; f([1, 2], nil); rescue TypeError => e; puts e.message; end

def g(a, x) = a.at(x)
p g(["a", "b"], 1)
p g([1, :x], 1.5)
begin; g(["a"], 0..0); rescue TypeError => e; puts e.message; end
begin; g({1 => 2}, 0..1); rescue NoMethodError => e; puts e.message; end
begin; g(["a"], "0"); rescue TypeError => e; puts e.message; end

class C
  def initialize(a) = (@a = a)
  def to_a = @a
  def at(*x) = to_a.at(x[0])
end
C.new([1, 2])
p C.new([[7, 8], 66]).at(1)
begin; C.new([1, 2]).at(0..1); rescue TypeError => e; puts e.message; end
