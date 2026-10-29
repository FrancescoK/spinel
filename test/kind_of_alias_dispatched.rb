# A kind query a program class only aliases (`alias kind_of? is_a?`) is
# the poly dispatch's: a boxed value that is one of that class answers
# with the alias, and every other value with the builtin class test.
class Dur
  def initialize(v) = @v = v
  def is_a?(klass)
    Dur == klass || @v.is_a?(klass)
  end
  alias kind_of? is_a?
end

# The aliased query may answer other than true or false: the call is then
# a box, and the builtin test's plain truth value is boxed for it.
class Tagged
  def initialize(tag) = @tag = tag
  def is_a?(klass) = @tag
  alias kind_of? is_a?
end

class Pt
  attr_reader :x
  def initialize(x) = @x = x
  def ==(r)
    r.kind_of?(Pt) && @x == r.x
  end
end

def check(year)
  raise ArgumentError, 'year must be an Integer' unless year.kind_of?(Integer)
  year
end

vals = [1, "s", Pt.new(2), Dur.new(3), Tagged.new(:yes)]
p Pt.new(2) == vals[2]
p Pt.new(2) == vals[0]
p check(vals[0])
begin
  check(vals[1])
rescue ArgumentError => e
  puts e.message
end
p vals[3].kind_of?(Integer)
p vals[3].kind_of?(Dur)
p vals[4].kind_of?(Integer)
p vals.map { |v| v.kind_of?(Integer) }
p vals.map { |v| v.kind_of?(Pt) }
