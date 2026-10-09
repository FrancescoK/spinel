# spinel: gc-minor
# A concrete method result keeps its selected String through this tail.
class A
  def initialize(x) = @x = x
  def get(k)
    case k
    when 0 then @x
    else @x + "c"
    end
  end
end
src = "s".dup
a = A.new(src)
h = {}
h[:a] = a.get(1)
h[:b] = a.get(0)
h[:a] << "?"
h[:b] << "!"
p h, src
