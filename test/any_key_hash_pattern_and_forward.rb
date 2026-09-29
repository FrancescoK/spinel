class AllMatcher; end
ANY = AllMatcher.new
h = {ANY => 1, do: 2, n: {b: 3}}
case h; in {do: 2} then p :lit; else p :no; end
case h; in {do:} then p binding.local_variable_get(:do); end
case h; in {n: {b:}} then p b; end
case h; in {do: Integer => x, **rest} then p [x, rest.size]; end
case h; in {zz:} then p :bad; else p :miss; end
h => {do: y}
p y
p((h in {do: 1 | 2}))
def pattern(**options) = (case options; in {do: Symbol => d} then d; else :none; end)
p pattern(ANY => :parked, do: :take_off), pattern(do: :x), pattern(ANY => 1)
class Forwarded
  def self.new(*a, **k) = super
  def initialize(x = 0, do: 0) = (@d = binding.local_variable_get(:do))
  attr_reader :d
end
p Forwarded.new(do: 2).d
Forwarded.new("s" => 1) if ARGV.size > 9
