# spinel: share
# spinel: gc-minor
# A begin with an ensure whose String value tails into a box (a boxed
# method return, a lambda's or a proc's value) boxes the String it
# answers, a shared one as its handle.
module M
  def lam(f)
    pr = -> { begin; return @x * 2 if f; @x; ensure; @y = @x.size; end }
    pr.call
  ensure
    @n = @x.size
  end
  def prc(f)
    pr = proc { begin; next @x * 2 if f; @x; ensure; @y = @x.size; end }
    pr.call
  end
  def assigned(f)
    return (@y = @x * 2) if f
    @x
  ensure
    @n = @x.size
  end
end
class A; include M; def initialize(x) = @x = x; end
class B
  def lam(f) = "b".dup
  def prc(f) = "c".dup
  def assigned(f) = "d".dup
end

src = "s".dup
os = [A.new(src), B.new]
r = os[0].lam(true)
r << "!"
q = os[0].lam(false)
q << "#"
p r, q, src, q.equal?(src), os[1].lam(1)

src = "s".dup
os = [A.new(src), B.new]
r = os[0].prc(true)
r << "!"
q = os[0].prc(false)
q << "#"
p r, q, src, q.equal?(src), os[1].prc(1)

src = "s".dup
os = [A.new(src), B.new]
r = os[0].assigned(true)
r << "!"
q = os[0].assigned(false)
q << "#"
p r, q, src, q.equal?(src), os[1].assigned(1)

# Repeated evaluation of a frozen arm answers the literal itself.
src = +"s"
l = ->(f) { begin; f ? src : "lit"; ensure; end }
xs = [l, 1]
d = xs[0].(false)
e = xs[0].(false)
p d.equal?(e), d.equal?("lit")
c = xs[0].(true)
c << "!"
p src
