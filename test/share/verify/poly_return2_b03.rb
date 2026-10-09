# procs/lambdas returning @x
class A
  def initialize(x) = @x = x
  def pr = proc { @x }
  def la(f) = ->() { f ? @x : @x + "l" }
end
src = "s".dup
a = A.new(src)
r = a.pr.call
r << "!"
p r, src
q = a.la(false).call
q << "?"
p q, src
t = a.la(true).call
t << "#"
p t, src
