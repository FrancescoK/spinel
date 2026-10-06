# A method that returns `to_enum(:m) unless block_given?` and otherwise
# answers a call's value (`@a.select { ... }`) answers that value when
# called with a block. Its return was pinned to Enumerator as for an
# each-like method, whose block form answers self, and the selected
# Array came back nil.
class Box
  def initialize = @a = [1, 2, 3]
  def pick
    return to_enum(:pick) unless block_given?
    @a.select { |x| yield x }
  end
  def doubled
    return enum_for(:doubled) unless block_given?
    @a.map { |x| yield(x) * 2 }
  end
  def each_item
    return to_enum(:each_item) unless block_given?
    @a.each { |x| yield x }
    self
  end
end
b = Box.new
p b.pick { |x| x > 1 }
p b.doubled { |x| x + 1 }
p b.each_item.to_a
p b.pick.class
