# super(*r) into a yielding parent spreads the splat across its parameters
class B
  def go(a, b = 3) = yield(a + b)
end
class S < B
  def go(*r, &blk) = super(*r, &blk)
end
p S.new.go(1) { |x| x * 2 }
p S.new.go(1, 5) { |x| x * 2 }

class S2 < B
  def go(x, *r, &blk) = super(x, *r, &blk)
end
p S2.new.go(1) { |x| x * 2 }
p S2.new.go(1, 5) { |x| x * 2 }

# with a keyword alongside the splat
class K
  def go(a, b = 3, k: 0) = yield(a + b + k)
end
class K2 < K
  def go(*r, &blk) = super(*r, k: 1, &blk)
end
p K2.new.go(1) { |x| x * 2 }
p K2.new.go(1, 5) { |x| x * 2 }

# into a rest with a post parameter
class R
  def go(a, *m, z) = yield([a, m, z])
end
class R2 < R
  def go(*r, &blk) = super(*r, &blk)
end
p R2.new.go(1, 2) { |v| v }
p R2.new.go(1, 2, 3, 4) { |v| v }

# explicit positionals into a rest parent
class R3 < R
  def go(x, &blk) = super(x, 7, 8, 9, &blk)
end
p R3.new.go(1) { |v| v }

# super(...) into a yielding parent taking only required parameters
class FB
  def go(a, b) = yield(a + b)
end
class F < FB
  def go(...) = super(...)
end
p F.new.go(1, 5) { |x| x * 2 }
p F.new.go(2, 5) { |x| x * 2 }

# a bare super in a method taking *rest spreads it too
class Z < B
  def go(*r, &blk) = super
end
p Z.new.go(1) { |x| x * 2 }
p Z.new.go(1, 5) { |x| x * 2 }

class Z2 < K
  def go(*r, k: 5, &blk) = super
end
p Z2.new.go(1) { |x| x * 2 }
p Z2.new.go(1, 2, k: 10) { |x| x * 2 }

class Z3 < R
  def go(x, *r) = super
end
p Z3.new.go(1, 2) { |v| v }
p Z3.new.go(1, 2, 3, 4) { |v| v }

class Z4 < B
  def go(*r) = super
end
begin
  Z4.new.go(1, 2, 3) { |x| x }
rescue ArgumentError => e
  p e.message
end

# ... and into a parent that does not yield
class N
  def go(a, b = 3, k: 0) = a + b + k
  def self.mk(a, b = 2) = a * b
end
class N2 < N
  def go(*r, k: 7) = super
  def self.mk(*r) = super
end
p N2.new.go(1)
p N2.new.go(1, 5, k: 1)
p N2.mk(4)
p N2.mk(4, 5)

class P
  def go(a, *m) = [a, m]
end
class P2 < P
  def go(*r) = super
end
p P2.new.go(1)
p P2.new.go(1, 5, 6)
