# A guarded each (`return to_enum(:each) unless block_given?`) that returns a
# copy of its receiver early (`return self.dup if @a.empty?`, `return clone`).
# The call counted as a value of the block form, so the method was not pinned
# to the Enumerator; the blockless call was then typed as the class, and an
# Enumerable consumer of it (`e.to_a`) was rewritten as a call on the class
# and refused. A call whose type is the receiver's class answers the receiver
# as `self` does.
class C
  include Enumerable
  def initialize(a) = @a = a

  def each
    return to_enum(:each) unless block_given?
    return self.dup if @a.empty?
    @a.each { |x| yield x }
    self
  end
end

c = C.new([1, 2, 3])
r = c.each { |x| x }
p r.class, r.equal?(c)
e = c.each
p e.class, e.next, e.to_a
p c.map { |x| x * 2 }, c.min
p C.new([]).each { }.class

class K
  include Enumerable
  def initialize(a) = @a = a

  def each
    return enum_for(:each) unless block_given?
    return clone if @a.empty?
    @a.each { |x| yield x }
    self
  end
end

k = K.new([4, 5])
p k.each.class, k.each.to_a, k.sort.reverse, k.each { }.equal?(k)
p K.new([]).each { }.class
