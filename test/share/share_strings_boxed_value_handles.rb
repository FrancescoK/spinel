# spinel: share
# spinel: gc-minor
# A String boxed where the rule shares the box's String keeps a handle:
# a polymorphic method's returns, a map block's values and a break's value.
# An append through the box then reaches every name that holds it.
module M
  def pick(v)
    case v
    in Integer => n if n > 5 then @x + "big"
    in Integer then @x
    in String => s then s
    else "other".dup
    end
  end
  def first_or(f) = (f && @x) || @x + "o"
  def mapped(f) = [1].map { |i| next @x if f; @x + "n" }.first
  def broke(f) = [1, 2].each { |i| break @x if f; break @x + "k" }
  def looped(n)
    i = 0
    while i < n
      i += 1
      break @x + "w" if i == 2
      break @x if i > 5
    end
  end
end
class A; include M; def initialize(x) = @x = x; end
class B
  def pick(v) = "b".dup
  def first_or(f) = "c".dup
  def mapped(f) = "d".dup
  def broke(f) = "e".dup
  def looped(n) = "f".dup
end

src = "s".dup
os = [A.new(src), B.new]
w = [os[0].pick(9), os[0].pick(1), os[0].pick(2.0), os[1].pick(1)]
w[0] << "!"
w[2] << "?"
p w, src
w[1] << "#"
p w, src, w[1].equal?(src)

src = "s".dup
os = [A.new(src), B.new]
w = [os[0].first_or(true), os[0].first_or(false), os[1].first_or(1)]
w[1] << "!"
p w, src
w[0] << "#"
p w, src

src = "s".dup
os = [A.new(src), B.new]
w = [os[0].mapped(true), os[0].mapped(false), os[1].mapped(1)]
w[1] << "!"
p w, src
w[0] << "#"
p w, src, w[0].equal?(src)

src = "s".dup
os = [A.new(src), B.new]
w = [os[0].broke(true), os[0].broke(false), os[0].looped(3), os[0].looped(9), os[1].broke(1)]
w[1] << "1"
w[2] << "2"
p w, src
w[3] << "3"
p w, src, w[0].equal?(src)

class C
  def initialize(x) = @x = x
  def built(f) = Array.new(2) { |i| next @x if f; @x + i.to_s }
  def chosen = Array.new(2) { |i| i > 0 ? @x : @x + "z" }
end
src = "s".dup
c = C.new(src)
w = c.built(false)
w[0] << "!"
v = c.built(true)
v[1] << "?"
u = c.chosen
u[0] << "#"
u[1] << "%"
p w, v, u, src

# a rescue arm's message in a boxed method: the String the thread raised
def raised_in_thread(s)
  th = Thread.new { Thread.current.report_on_exception = false; raise s }
  begin
    th.value
  rescue => e
    e.message
  end
end
s = +"src"
t = raised_in_thread(s)
p t.equal?(s)
t << "x"
p s

# a frozen literal a boxed method answers stays the literal: the same
# object on each call, still frozen
class D
  def initialize(x) = @x = x
  def get(k) = k > 1 ? @x : (k > 0 ? "lit" : [1])
end
src = +"s"
d = D.new(src)
w = [d.get(2), d.get(1), d.get(1)]
w[0] << "!"
p w[1].equal?(w[2]), w[1].frozen?, src
begin
  w[1] << "x"
rescue FrozenError
  p :frozen
end
