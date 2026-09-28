# A poly-dispatch arm evaluates a default that reads an earlier parameter
# inside the arm, and only for the receiver's own class: the default's
# hoisted statements used to land ahead of the switch, before the arm's
# parameter locals existed.
class P; def m(a, b = [a + 1]) = [a, b]; end
class Q < P; def m(a, b = [a + 2]) = [a, b]; end
[P.new, Q.new].each { |o| p o.m(1) }

class D
  def initialize = (@x = 10)
  def m(a, k: [a + @x]) = [a, k]
end
class E < D; def m(a, k: [a * 2, self.class.name]) = [a, k]; end
class F < D; def m(a, k: { a => a }) = [a, k]; end
[D.new, E.new, F.new].each { |o| p o.m(1); p o.m(2, k: 5) }

class G
  def initialize = (@x = 10)
  def m(a, b = [a + @x], c = b.size + a) = [a, b, c]
end
class H < G; def m(a, b = "s#{a}", c = [b, a]) = [a, b, c]; end
class I < G; def m(a, b = a.to_s * 2, c = { b => [a] }) = [a, b, c]; end
[G.new, H.new, I.new].each { |o| p o.m(1); p o.m(3, [7]) }

class S; def n(a, *r, b: [a, r.size]) = [a, r, b]; end
class T; def n(a, *r, b: [r, a]) = [a, r, b]; end
[S.new, T.new].each { |o| p o.n(1, 2, 3) }

class J; def m(a, b = [puts("J"), 1]) = b; end
class K; def m(a, b = [puts("K"), 2]) = b; end
[J.new, K.new].each { |o| p o.m(4) }

class L; def m(a, b = [a + 1]); puts "L#{a}#{b}"; end; end
class M; def m(a, b = [a + 2]); puts "M#{a}#{b}"; end; end
[L.new, M.new].each { |o| o.m(1) }
