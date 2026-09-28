# A `**h` yielded to a block that takes no keywords is a positional only
# when h is non-empty: yield(**{}) yields nothing.

def y(h) = yield(**h)
y({}) { |*a| p a }
y({k: 1}) { |*a| p a }
p(y({}) { |a| a })
p(y({q: 1}) { |a| a })

def y1(h) = yield(1, **h)
y1({}) { |*a| p a }
y1({k: 1}) { |*a| p a }
y1({}) { |a, b = :d| p [a, b] }
y1({k: 1}) { |a, b = :d| p [a, b] }
y1({}) { |a, b| p [a, b] }
y1({}) { |*r, z| p [r, z] }
y1({q: 1}) { |*r, z| p [r, z] }
y1({}) { |a, k: 5| p [a, k] }
p(y1({}) { |*a| a.size })

def y2(h, g) = yield(**h, **g)
y2({}, {}) { |*a| p a }
y2({}, {m: 1}) { |*a| p a }

class C
  def initialize; @h = {}; end
  def run = yield(:s, **@h)
end
C.new.run { |*a| p a }

def c(h, &b) = b.call(1, **h)
c({}) { |a, b = :d| p [a, b] }
c({z: 1}) { |a, b = :d| p [a, b] }

def ya(h) = yield([1, 2], **h)
ya({}) { |a, b| p [a, b] }
ya({k: 2}) { |a, b| p [a, b] }
ya({}) { |a, | p a }
ya({}) { |a, *r| p [a, r] }
ya({}) { |a, b = 3| p [a, b] }

# a block that arrives as a proc: a recursive (lowered) yielder, a forwarded &proc
def r(n, h, &b)
  return yield(n, **h) if n == 0
  r(n - 1, h, &b)
end
p(r(2, {}) { |*a| a.size })
p(r(2, {k: 1}) { |a, b = :d| b })
def rs(n, h, &b)
  if n == 0
    yield(**h)
    return 7
  end
  rs(n - 1, h, &b)
end
p(rs(1, {}) { |*a| p a })
pr = proc { |a, b = :d| p [a, b]; b }
def z(h) = yield(1, **h)
p z({}, &pr)
p z({q: 2}, &pr)
def zz(h)
  yield(**h)
  :done
end
p zz({}, &pr)
def za(a) = yield(0, *a)
p(za([1, 2], &proc { |*x| x }))
begin
  z({})
rescue LocalJumpError => e
  p e.message
end
