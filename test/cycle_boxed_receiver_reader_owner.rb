class Rd
  attr_reader :cycle
  def initialize = @cycle = 42
end
def f(o) = o.cycle
[Rd.new, [1, 2]].each { |v| x = f(v); p(x.is_a?(Integer) ? x : x.first(3)) }
