# Each-like methods whose block form runs an iteration and whose other paths
# `raise` or `fail`: a guard `raise IOError, "closed stream" if @closed` before
# the iteration, an `if`/`else` whose `else` raises, an `unless`/`else` whose
# `else` fails. A raise is a call, and a call that is not an iteration counts as
# a value in the search of the method's tail and of the guards before it, which
# is what keeps these methods from being pinned to the Enumerator of their
# `return to_enum unless block_given?` guard: the block form answers what the
# iteration answers (the Array), as CRuby does, where a pinned one answered nil.
class Lines
  def initialize(a) = (@a = a; @closed = false)
  def each
    return enum_for(:each) unless block_given?
    raise IOError, "closed stream" if @closed
    @a.each { |x| yield x }
  end
end

class Items
  def initialize(a, m) = (@a = a; @m = m)
  def each
    return to_enum(:each) unless block_given?
    if @m == :ok then @a.each { |x| yield x }
    else raise ArgumentError, "mode"
    end
  end
end

class Stack
  def initialize(a) = @a = a
  def each
    return to_enum(:each) unless block_given?
    unless @a.empty?
      @a.each { |x| yield x }
    else
      fail "empty"
    end
  end
end

l = Lines.new(["a", "b"])
p l.each.to_a
p l.each { |x| x }
i = Items.new([3, 1, 2], :ok)
p i.each.to_a
p i.each.map { |x| x + 1 }
p i.each { |x| x }
s = Stack.new([1, 2])
p s.each { |x| x }
p s.each.to_a
