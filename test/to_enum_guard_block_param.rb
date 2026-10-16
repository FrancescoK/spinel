# `return to_enum(:m) unless block` guarded by the block parameter rather
# than block_given?: the method is one function taking the block, and it
# answers the Enumerator without one and its `self` tail with one

class A
  def each_value(&block)
    return to_enum(__method__) unless block

    [1, 2].each(&block)
    self
  end

  def each_key(&blk)
    return enum_for(:each_key) unless blk
    %w[a b].each(&blk)
    self
  end
end

a = A.new
p a.each_value { |x| p x }.class
e = a.each_value
p e.class
p e.to_a
p a.each_key { |k| p k }.equal?(a)
p a.each_key.map(&:upcase)
