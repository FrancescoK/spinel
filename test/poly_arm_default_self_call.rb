# A default that calls a method of the callee's own class, reached through
# a receiver of run-time type: the dispatch arm spelled the call for the
# caller's class and raised NameError. Rack's Utils.unescape_path calls
# URI::RFC2396_Parser#unescape(str, escaped = regexp[:ESCAPED]) this way.

class P
  def initialize = @n = 1
  def tbl = { a: "A" }
  def un(s, e = tbl[:a]) = "#{s}#{e}#{@n}"
  def kw(s, e: tbl[:a] * 2) = "#{s}#{e}"
  def hidden(s, e = secret) = "#{s}#{e}"

  private

  def secret = "S"
end

class Q
  def un(s, e = nil) = "#{s}#{e}q"
  def kw(s, e: "k") = "#{s}#{e}"
  def hidden(s, e = "h") = "#{s}#{e}"
end

module U
  module_function

  def go(o, s) = [o.un(s), o.kw(s), o.hidden(s)]
end

p U.go(P.new, "x")
p U.go(Q.new, "y")

# the caller is a class with a method of the same name: the default still
# calls the callee's
class R
  def tbl = { a: "wrong" }
  def go(o) = o.un("z")
end
p R.new.go(P.new), R.new.go(Q.new)

# inherited: the default's call dispatches on the receiver
class S < P
  def tbl = { a: "sub" }
end
p U.go(S.new, "w")

# no arguments at all, a splat and a ** hash take the same arms
class P
  def z(e = tbl[:a]) = "z#{e}"
end
class Q
  def tbl = { a: "wrong" }
  def z(e = 0) = "q"
end
class R
  def go0(o) = o.z
  def go1(o, args, h) = [o.un(*args), o.kw("b", **h)]
end
p R.new.go0(P.new), R.new.go0(Q.new)
p R.new.go1(P.new, ["s"], {}), R.new.go1(Q.new, ["t"], {})

# a Symbol's proc over a mixed Array, from a class with its own tbl
class Q
  def all(a) = a.map(&:z)
end
p Q.new.all([P.new, Q.new])

# a default whose operands are held ahead of the call reads them inside
# the arm, on its receiver (it read a receiver not there yet and crashed)
class P
  def y(e = @n + bump) = "y#{e}"
  def y2(e = @n + self.bump) = "y#{e}"
  def bump = 10
end
class Q
  def y(e = 0) = "qy"
  def y2(e = 0) = "qy"
end
class R
  def ys(o) = [o.y, o.y2]
end
p R.new.ys(Q.new), R.new.ys(P.new)

# a later default with an effect runs after an earlier default's read
class P2
  def initialize = @n = 1
  def z(a = @n, b = (@n += 1)) = [a, b]
  def y(a = @n, b = (@n += 1), c = @n) = [a, b, c]
end
class Q2
  def z(a = 0, b = 0) = :q
  def y(a = 0, b = 0, c = 0) = :q
end
class R
  def zy(o) = [o.z, o.y]
end
p R.new.zy(Q2.new), R.new.zy(P2.new)
