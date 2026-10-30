module L
  def each = super { |x| yield x * 10 }
end
class K
  include Enumerable
  def each
    yield 1
    yield 2
  end
end
k = K.new
def go(k) = [k.map { |x| x + 1 }, k.to_a]
p go(k)
class K; prepend L; end
p go(k)
