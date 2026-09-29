# A merge conflict block whose value needs setup (a constructor call on a
# computed argument) runs it for each colliding pair, after the block's
# parameters are bound -- not once ahead of the loop on their nil.

class Pt
  def initialize(v) = @v = v
  def inspect = "Pt(#{@v})"
end

h = {"a" => 1, "b" => "x"}
h.update({"a" => 2, "c" => "y"}) { |_k, o, n| Pt.new(o + n) }
p h

g = {"a" => 1, "b" => "x"}
g.merge!({"a" => 5, "b" => "z"}) { |_k, o, n| Pt.new(o + n) }
p g

m = {"a" => 1, "b" => "x"}
r = m.merge({"a" => 4}) { |_k, o, n| Pt.new(o * n) }
p r
