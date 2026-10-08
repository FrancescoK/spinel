# spinel: gc-minor
# A concrete method result keeps its selected String through this tail.
class A
  def initialize(x) = @x = x
  def get(f)
    begin
      raise "x" if f
      @x
    rescue
      @x + "r"
    end
  end
end
src = "s".dup
a = A.new(src)
w = [a.get(false), a.get(true)]
w[0] << "!"
w[1] << "?"
p w, src
