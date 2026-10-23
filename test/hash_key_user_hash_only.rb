# A class that defines #hash but keeps Object#eql?: each key is itself only,
# and every place that hashes the key calls the method
class K
  attr_reader :n
  def initialize(n) = @n = n
  def hash
    $calls += 1
    7
  end
end
$calls = 0
a = K.new(1)
b = K.new(2)
h = { a => :a }
h[b] = :b
p h.size, h[a], h[b], h[K.new(1)]
p h.key?(a), h.key?(K.new(2))
h.delete(a)
p h.size
p $calls > 0
