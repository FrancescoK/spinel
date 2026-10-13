# A forwarded &block that becomes a yield (`@h.each(&block)`) makes the method a
# yielding one, also when another class's method of the name keeps its block
# (tty-prompt's Choices#each answers to_enum without one): thor's
# HashWithIndifferentAccess built from another one walked it through a box
# and its yield raised LocalJumpError.
class Indifferent
  def initialize(hash = {})
    @h = {}
    hash.each { |k, v| @h[k.to_s] = v }
  end

  def each(&block)
    @h.each(&block)
  end
end
class Rows
  def initialize(a) = @a = a
  def each(&block)
    return to_enum unless block
    @a.each(&block)
  end
end
b = Indifferent.new(Indifferent.new({ a: 1 }))
b.each { |k, v| p [k, v] }
Rows.new([1]).each { |x| p x }
p Rows.new([3]).each.to_a
