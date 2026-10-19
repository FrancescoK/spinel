# `to_enum(__method__, ...)` from a method taking keyword arguments: the
# Enumerator calls the method again with the same keywords.
class Node
  attr_reader :name, :parent

  def initialize(name, parent = nil)
    @name = name
    @parent = parent
  end

  def each_ancestor(include_self: false)
    return to_enum(__method__, include_self: include_self) unless block_given?
    n = include_self ? self : parent
    while n
      yield n
      n = n.parent
    end
    self
  end

  def each_up(step, limit:, tag: "-")
    return enum_for(:each_up, step, limit: limit, tag: tag) unless block_given?
    i = 0
    while i < limit
      yield "#{tag}#{name}#{i}"
      i += step
    end
  end
end

a = Node.new(:a)
b = Node.new(:b, a)
c = Node.new(:c, b)
p c.each_ancestor.map(&:name)
p c.each_ancestor(include_self: true).map(&:name)
p c.each_ancestor(include_self: true).first.name
p c.each_ancestor.to_a.size
c.each_ancestor { |n| p n.name }
p a.each_up(2, limit: 5).to_a
p a.each_up(1, limit: 2, tag: "+").map(&:upcase)
p b.each_up(3, limit: 7).with_index.map { |s, i| [i, s] }
