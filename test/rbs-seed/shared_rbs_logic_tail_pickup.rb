# Under --share-strings (#6765), a method an --rbs signature declares
# `-> String` whose tail is a boxed `||` or `&&` with an operand that is a
# call answering a shared String (`v || s`, `s || v`, `(v or s)`, `v && s`,
# `k || s` over a local) answers that String itself: the operand is boxed
# from the handle its call publishes, as an unseeded method's tail boxes it,
# not from its bytes, which held no handle and gave the caller a copy. The
# tail was refused for that reason; a caller that changes the buffer after
# the call sees the change through the answer (CRuby 4.0: the same object).
# An operand that answers a new String is boxed as a new handle.
# spinel: rbs-seed-check
module LtConf
  class << self
    attr_accessor :key
  end
end

class LtApp
  def initialize(s)
    @s = s
  end

  def s = @s

  def fresh = @s.upcase

  def or_right(v)
    v || s
  end

  def or_left(v)
    s || v
  end

  def or_paren(v)
    (v or s)
  end

  def and_right(v)
    v && s
  end

  def or_local
    k = LtConf.key
    k || s
  end

  def or_fresh(v)
    v || fresh
  end
end

def pass(x) = x

def check(label, buf, y)
  buf << "!"
  p [label, y, y.equal?(buf)]
end

b = +"ab"
b << "c"
a = LtApp.new(b)
check(:or_right, b, pass(a.or_right(nil)))

b = +"ab"
b << "c"
a = LtApp.new(b)
check(:or_left, b, pass(a.or_left(nil)))

b = +"ab"
b << "c"
a = LtApp.new(b)
check(:or_paren, b, pass(a.or_paren(nil)))

b = +"ab"
b << "c"
a = LtApp.new(b)
check(:and_right, b, pass(a.and_right(1)))

b = +"ab"
b << "c"
a = LtApp.new(b)
LtConf.key = nil
check(:or_local, b, pass(a.or_local))

# the other operand wins: its own String, not the buffer
b = +"ab"
b << "c"
a = LtApp.new(b)
other = +"zz"
y = pass(a.or_right(other))
other << "!"
p [y, y.equal?(other), y.equal?(b)]
y = pass(a.or_left(other))
b << "?"
p [y, y.equal?(b)]
LtConf.key = other
y = pass(a.or_local)
other << "#"
p [y, y.equal?(other)]

# a new String answered by the call is a new String
b = +"ab"
b << "c"
a = LtApp.new(b)
y = pass(a.or_fresh(nil))
b << "!"
p [y, y.equal?(b)]
