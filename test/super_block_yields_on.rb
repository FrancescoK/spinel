# A block passed to super that yields on to the method's own block, or calls
# its &block parameter, reaches the caller's block -- through one override
# or a chain of them.

class P
  def e = [1, 2].each { |v| yield v }
  def m(a) = yield(a + 1)
  def two = yield(1, 2)
end

class K < P
  def e = super { |v| yield v * 10 }
  def m(a) = super(a * 2) { |v| yield(v) + 100 }
  def two = super { |a, b| yield b, a }
end

K.new.e { |x| p x }
p K.new.m(3) { |x| x * 10 }
K.new.two { |x, y| p [x, y] }

class A
  def e = yield(1)
end

class B < A
  def e = super { |v| yield v + 1 }
end

class C < B
  def e = super { |v| yield v * 10 }
end

class D < C
  def e = super { |v| yield v - 3 }
end

p C.new.e { |x| x }
p D.new.e { |x| x }

class Q
  def e = yield(1)
end

class R < Q
  def e(&b) = super { |v| b.call(v * 10) }
end

class S < R
  def e(&c) = super { |v| c.call(v + 5) }
end

p R.new.e { |x| x }
p S.new.e { |x| x }

class T < Q
  def e(&b)
    r = super { |v| b.call(v) + b.call(v + 1) }
    [r, b.call(9)]
  end
end

p T.new.e { |x| x * 3 }

class U < Q
  def e(&b) = super { |v| b ? b.call(v) : :none }
end

p U.new.e { |x| x + 1 }
p U.new.e
