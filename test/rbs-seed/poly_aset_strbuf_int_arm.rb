# A poly `[]=` passing a mutable String does not take the arm of a class
# whose value parameter is seeded Integer (#4929)
# spinel: rbs-seed-check
class SeedCounter
  def initialize = @n = 0
  def []=(name, value)
    @n = value if name == :n
    value
  end
  def n = @n
end

def opts(flag) = flag ? { class: "a" } : SeedCounter.new

o = opts(true)
v = String.new; v << "b"; o[:class] = v
p o
c = opts(false)
c[:n] = 3
p c.n
