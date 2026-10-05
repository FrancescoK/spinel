# A reopened Time's `<=>` answers for a boxed Time in the runtime
# comparator (sort, min, max), as its operators do: activesupport chains
# Time#<=> through compare_with_coercion. The comparator's table keyed the
# reopening by its class index, which no boxed Time carries, named a
# function that does not exist, and the C did not compile.
class Stamp
  attr_reader :sec
  def initialize(s) = @sec = s
end
class Time
  def compare_with_coercion(other)
    other = Time.at(other.sec) if other.is_a?(Stamp)
    compare_without_coercion(other)
  end
  alias_method :compare_without_coercion, :<=>
  alias_method :<=>, :compare_with_coercion
end
t = Time.at(100)
p (t <=> Stamp.new(50))
p (t <=> Time.at(200))
vals = [Time.at(30), Time.at(10), Time.at(20)]
p vals.sort.map(&:to_i)
p vals.max.to_i
boxed = [Time.at(5), "x"]
p (boxed[0] <=> Stamp.new(9))

# the captured builtin runs inside the program's operator: an operand it
# rejects raises, rather than coming back to the program's method for good
class Opaque; end
class Time
  def minus_with_coercion(o) = minus_without_coercion(o)
  alias_method :minus_without_coercion, :-
  alias_method :-, :minus_with_coercion
end
begin
  [Time.at(1), 1][0] - Opaque.new
rescue TypeError => e
  p e.class
end
p ([Time.at(9), 1][0] - 4).to_i
