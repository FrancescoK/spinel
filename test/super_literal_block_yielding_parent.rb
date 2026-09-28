# A literal block on `super` is the one the yielding parent runs: the super's
# value is the block's, and the block's params are what the parent yields.

class B
  def go(a, b = 3) = yield(a + b)
end

class S < B
  def go(x) = super(x) { |y| y * 3 }
end

class T < B
  def go(x) = super { |y| y * 5 }
end

class U < B
  def go(x)
    r = super(x, 10) { |y| y.to_s + "!" }
    r + "?"
  end
end

p S.new.go(1)
p T.new.go(1)
p U.new.go(1)
p B.new.go(2) { |z| z }

class Base
  def each_pair(a) = yield(a, a.to_s)
end

class Kid < Base
  def each_pair(x) = super(x) { |n, s| s * n }
end

p Kid.new.each_pair(3)

class Acc
  def run(a)
    yield(a + 1)
    yield(a)
  end
end

class Collect < Acc
  def run(x)
    got = []
    super(x) { |y| got << y * x }
    got
  end
end

class Sum < Acc
  def run(x)
    n = 0
    super(x) { |y| n += y }
    n
  end
end

p Collect.new.run(2)
p Sum.new.run(4)

class CB
  def self.go(a) = yield(a + 1)
end

class CS < CB
  def self.go(x)
    k = 7
    super(x) { |y| y * k }
  end
end

p CS.go(1)
