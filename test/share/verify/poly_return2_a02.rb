# while loop with break value String, mono and poly
class A
  def initialize(x) = @x = x
  def get(n)
    i = 0
    r = while i < 3
      i += 1
      break @x if i == n
      break @x + "b" if i == 2
    end
    r || @x
  end
end
class B; def get(n) = "b".dup; end
src = "s".dup
a = A.new(src)
w = [a.get(1), a.get(2), a.get(9)]
w[1] << "!"
p w, src
os = [A.new(src), B.new]
v = [os[0].get(1), os[0].get(2), os[1].get(1)]
v[1] << "?"
p v, src
v[0] << "#"
p v, src
