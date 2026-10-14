# an Enumerator over a method that yields several values at once
# (to_enum(:m), enum_for(__method__)) hands each step on as those values: a
# Symbol#to_proc block calls the first's method with the rest, a `|x, y|`
# block takes them spread, a `|x|` block the first, and the class the
# values carry is one the call on them can reach

class P
  def add(o) = 10 + o
  def inspect = "P"
end

def two
  yield P.new, 5
  yield P.new, 6
end
p to_enum(:two).map(&:add)
p to_enum(:two).map { |x, y| x.add(y) }
p to_enum(:two).map { |x| x }
p enum_for(:two).to_a

class Q
  def two = yield(P.new, 7)
  def each_pair_of
    return enum_for(__method__) unless block_given?
    yield P.new, 8
    yield 1
    yield
  end
end
p Q.new.to_enum(:two).map(&:add)
p Q.new.each_pair_of.to_a
p Q.new.each_pair_of.map { |x| x }
