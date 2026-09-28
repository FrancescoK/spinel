# A yielding method is spliced in at each call site, so a default that reads
# an earlier parameter reads the inlined parameter, and self is the receiver.

class U
  def initialize; @n = 10; end
  def y(a, b = [a]) = yield(a, b)
  def kw(a, k: a * 2) = yield(a, k)
  def iv(a, b = @n + a, c = self.class) = yield(a, b, c)
  def blk(a, b = [a].map { |v| v * 3 }) = yield(a, b)
  def pr(a, b = a + 1, &blk) = blk.call(a, b)
  def twice(a, b = pick(a) { |v| v * 2 }) = yield(a, b)
  def pick(v) = yield(v)
  def self.cm(a, b = a + 1) = yield(a, b)
end

p U.new.y(4) { |x, z| [x, z] }
p U.new.y(4, [0]) { |x, z| [x, z] }
p U.new.kw(4) { |x, z| [x, z] }
p U.new.kw(4, k: 1) { |x, z| [x, z] }
p U.new.iv(4) { |x, z, w| [x, z, w] }
p U.new.blk(4) { |x, z| [x, z] }
p U.new.pr(4) { |x, z| [x, z] }
p U.new.twice(4) { |x, z| [x, z] }
k = U
p k.cm(4) { |x, z| [x, z] }
p U.cm(5) { |x, z| [x, z] }

a = 100
p U.new.y(4) { |x, z| [x, z, a] }
p U.new.y(U.new.y(1) { |x, z| x + z.size }) { |x, z| [x, z] }

def top(a, b = a + 1) = yield(a, b)
p top(4) { |x, z| [x, z] }
p top(4, 9) { |x, z| [x, z] }

class Other
  def initialize; @n = 20; end
  def go = U.new.iv(1) { |x, z, w| [x, z, w, @n] }
end
p Other.new.go

class Built
  def initialize(a, b = a * 2); @v = yield(a, b); end
  attr_reader :v
end
p Built.new(3) { |x, z| x + z }.v

class Base
  def initialize; @n = 10; end
  def sy(a, b = a + @n) = yield(a, b)
end
class Sub < Base; def sy(a) = super(a); end
p Sub.new.sy(4) { |x, z| [x, z] }

class A; def py(a, b = a + 1) = yield(a, b); end
class B; def py(a, b = a + 2) = yield(a, b); end
[A.new, B.new].each { |o| p o.py(4) { |x, z| [x, z] } }
[A.new, B.new].each { |o| p o.py(4, 0) { |x, z| [x, z] } }

class KA; def pk(a, k: a.to_s * 2) = yield(a, k); end
class KB; def pk(a, k: a.to_s) = yield(a, k); end
[KA.new, KB.new].each { |q| p q.pk(4) { |x, z| [x, z] } }

class CBase
  def self.m(a, b = self) = yield(a, b)
  def self.n(a, b = name) = yield(a, b)
  def self.w(a, b = new) = yield(a, b.class)
  def self.q = yield(name)
end
class CSub < CBase; end
p CSub.m(1) { |x, y| [x, y] }
p CBase.m(1) { |x, y| [x, y] }
p CSub.n(2) { |x, y| [x, y] }
p CBase.n(2) { |x, y| [x, y] }
p CSub.w(3) { |x, y| [x, y] }
p CBase.w(3) { |x, y| [x, y] }
cs = CSub
p cs.m(4) { |x, y| [x, y] }
p CSub.q { |x| x }
