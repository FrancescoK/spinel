# The reflection on a value whose class Spinel cannot see statically -- a
# parameter given a Hash at one site and a program object at another --
# reaches the builtin value's own ivars, as CRuby's does: the set used to
# be dropped and the get answered nil. A frozen value or an immediate
# raises FrozenError. (The call-binding probe's case 542.)

class Q
  def inspect = "q"
end

class B
  def m(p1 = Q.new, p2 = Q.new, p3, k1: 70)
    [(p1.instance_variable_set(:@z, 7) rescue nil; p1.instance_variable_get(:@z)), p2, p3, k1]
  end
end

class C < B
  def m
    s = [{ v: 1 }, 2]
    h = nil
    blk = proc { :blk }
    super(*s, **h, &blk)
  end
end

p C.new.m
p B.new.m(3)

def mark(x, v)
  x.instance_variable_set(:@mark, v)
  [x.instance_variable_get(:@mark), x.instance_variable_defined?(:@mark), x.instance_variables]
end

p mark([1, 2], :arr)
p mark({a: 1}, :hash)
p mark(Q.new, :obj)
p mark(Random.new(1), :rng)
p((mark(5, :int) rescue $!.message))
p((mark(:sym, :s) rescue $!.message))
p((mark([3].freeze, :f) rescue $!.message))

class ReportedError < StandardError; end
begin
  raise ReportedError, "bad"
rescue => e
  p mark(e, true)
end

# the same set sent by name
arr = [1]
y = rand > 2 ? 1 : arr
y.send(:instance_variable_set, :@q, 5)
p arr.instance_variable_get(:@q), y.instance_variable_get(:@q)

# a Proc and a class reached the same way: a class's ivar is the one its
# class methods read, and one it does not declare lives beside it (a class
# lists the ivars only its class methods wrote after the reflective sets:
# sorted here, see docs/limitations.md)
class Foo
  def self.x = @x
  def self.setx(v) = (@x = v)
end
class Bar
  class << self
    attr_accessor :level
  end
end
def other(x, v)
  x.instance_variable_set(:@other, v)
  [x.instance_variable_get(:@other), x.instance_variables.sort]
end
def level(x, v)
  x.instance_variable_set(:@level, v)
  x.instance_variable_get(:@level)
end
p mark([Foo, 1][0], 5), Foo.x
Foo.setx(6)
p mark([Foo, 1][0], 7), Foo.x
p other([Foo, 1][0], :o), other([1], 2)
p level([Bar, 1][0], 3), Bar.level, level({}, 4)
p mark(String, "s"), mark(Comparable, 1)
pr = proc { 1 }
p mark(pr, :v), mark(lambda { 2 }, 1), pr.call

# a name computed at run time is checked as #7522's reflection checks it
names = ["@ok", "@x!", "x", :@sym]
names.each do |n|
  a = [1]
  p((a.instance_variable_set(n, 1) rescue $!.class), (a.instance_variable_get(n) rescue $!.class),
    (a.instance_variable_defined?(n) rescue $!.class), a.instance_variables)
end
p(([].instance_variable_get(42) rescue $!.class))
