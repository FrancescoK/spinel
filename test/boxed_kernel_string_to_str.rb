# String(obj) on an object read out of a container asks #to_str first and
# only then #to_s, as on a typed object.
class S
  def to_str = "str!"
  def to_s = "s!"
end
class T
  def to_s = "t!"
end
class A
  def to_str = "a-str"
end
# a to_s that allocates before it reads its object
class G
  def initialize(n) = @n = n
  def to_s
    junk = []
    3.times { junk << G.new(-1) }
    "g#{@n}"
  end
end
def mk(i) = i >= 0 ? G.new(i) : 0
x = [S.new, 0][0]
p String(x)
p String([T.new, 0][0])
p String([A.new, 0][0])
p String([5, "s"][0])
p String(["lit", 0][0])
p String([nil, 0][0])
p [S.new, T.new, 7].map { |v| String(v) }
p (0...50).all? { |i| String(mk(i)) == "g#{i}" }
