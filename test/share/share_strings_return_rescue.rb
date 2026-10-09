# spinel: gc-minor
# Rescue arms clear an earlier publication when returning a fresh String.
class A
  def initialize(x) = @x = x
  def get(k)
    begin
      raise "e" if k == 1
      @x
    rescue
      @x + "r"
    end
  end
end
src = "s".dup
a = A.new(src)
v = a.get(1)
v << "?"
u = a.get(0)
u << "!"
p v, u, src
