# A `return nil` written in a lambda of a guarded each leaves the lambda, not
# the method, and is no value of the method. It was counted as a nil path of
# the block form, so the result of a call with a block beside an Integer was
# boxed for no reason; the result stays an Integer slot now (the generated C
# declares `sp_int`, not `sp_RbVal`), and answers the same.
class C
  def initialize(n) = @n = n

  def each
    return to_enum(:each) unless block_given?
    l = -> { return nil }
    l.call
    @n.times { |i| yield i }
  end
end

r = C.new(3).each { }
p r + 1
p C.new(2).each.to_a
