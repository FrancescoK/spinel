# A method that returns early, before `return to_enum(:m) unless block_given?`
# (`return 0 if @a.nil?`, `return self if @a.nil?`). The guard was taken to
# stop every blockless call, so the call was typed as the Enumerator alone:
# the early return's 0 was read as nil, and an early `return self` was
# assigned into an Enumerator slot (the C did not build). A blockless call
# answers either now, as CRuby does.
class A
  def initialize(a) = @a = a

  def walk
    return 0 if @a.nil?
    return to_enum(:walk) unless block_given?
    @a.each { |x| yield x }
    self
  end
end

a = A.new([1, 2])
p a.walk { }.equal?(a), a.walk.to_a, A.new(nil).walk

class B
  def initialize(a) = @a = a

  def walk
    return self if @a.nil?
    return to_enum(:walk) unless block_given?
    @a.each { |x| yield x }
    self
  end
end

b = B.new([1, 2])
p b.walk { }.equal?(b), b.walk.to_a, B.new(nil).walk.class
