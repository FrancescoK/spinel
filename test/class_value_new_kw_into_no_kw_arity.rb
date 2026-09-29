# A Class value's `new` with literal keywords, reaching a class whose
# initialize takes no keywords: the keywords are one positional Hash, and a
# count that does not fit is CRuby's "wrong number of arguments".

class A
  def initialize(x, k: 0) = (@x = x; @k = k)
  def to_s = "A(#{@x},#{@k})"
end

class B
  def initialize(x, &handler) = (@x = x; @h = handler)
  def to_s = "B(#{@x})"
end

class C
  def initialize(x, y = 2, z = 3) = @s = [x, y, z]
  def to_s = "C#{@s}"
end

TYPES = { 0 => A, 1 => B, 2 => C }.freeze

def build(i, x) = TYPES.fetch(i).new(x, k: 1) { |v| v }
def build2(i) = TYPES.fetch(i).new(1, 2, 3, k: 1)

B.new(9) { |v| v }
puts build(0, 5).to_s
begin
  puts build(1, 6).to_s
rescue ArgumentError => e
  puts e.message
end
puts build(2, 7).to_s
begin
  puts build2(2).to_s
rescue ArgumentError => e
  puts e.message
end
