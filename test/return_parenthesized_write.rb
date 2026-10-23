# spinel: not-cruby
# A parenthesized local write still cannot publish a mixed return handle.
class A
 def initialize(x) = @x = x
 def get(k) = k == 0 ? @x : (s = @x + "p")
end
src = "s".dup
a = A.new(src)
x = a.get(1)
x << "?"
y = a.get(0)
y << "!"
p x,y,src
