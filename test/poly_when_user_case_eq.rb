# `when obj` against a subject read out of a container asks the arm's own
# === (or ==), as CRuby does, in a case statement and a case value.
class Even
  def ===(x)
    x.is_a?(Integer) && x.even?
  end
end
class Named
  attr_accessor :n
  def initialize(n) = @n = n
  def ==(o)
    o.is_a?(String) && o == "n#{@n}"
  end
end
EV = Even.new
def k(v)
  case v
  when EV then :even
  when Integer then :odd
  else :other
  end
end
p [2, 3, "s"].map { |v| k(v) }
n = Named.new(1)
[["n1", 0][0], ["n2", 0][0], [4, "s"][0]].each do |y|
  case y
  when n then p :named
  when EV then p :even
  else p :no
  end
end
x = [8, "s"][0]
p(case x; when Even.new then :fresh; else :no; end)
# an === a superclass defines
class Base2
  def ===(x) = x == 7
end
class Sub2 < Base2; end
p(case [7, "s"][0]; when Sub2.new then :sub; else :no; end)
# an arm that is nil matches a nil subject alone
class M2
  def initialize(n) = @n = n
  def ===(x) = x == @n
end
def pick(f) = f ? M2.new(1) : nil
[1, nil].each { |v| p(case [v, "s"][0]; when pick(false) then :hit; else :no; end) }
# an arm built for the test, whose === allocates before it reads the arm
class Mt
  def initialize(t) = @tag = t
  def ===(x)
    8.times { Mt.new("junk") }
    x == @tag
  end
end
miss = 0
200.times do |i|
  s = ["t#{i}", 1][0]
  miss += 1 unless (case s; when Mt.new("t#{i}") then true; else false; end)
end
p miss
