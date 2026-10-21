# A method that hands its own rest parameter (and block) on to a builtin of
# the same name, on a receiver that is a reader or another call rather than
# a local or an ivar, picks the builtin's arity by the rest's size, as
# `@items.last(*args)` does: `last` with no argument is the last element,
# not a one-argument call that raises. The receiver runs once.
class Box
  attr_accessor :items, :table, :text

  def initialize
    @items = [10, 20, 30, 40]
    @table = { a: 1, b: 2 }
    @text = "hello world"
    @reads = 0
  end

  def counted
    @reads += 1
    @items
  end

  attr_reader :reads

  def last(*args) = items.last(*args)
  def first(*args, &block) = items.first(*args, &block)
  def take(*args) = items.take(*args)
  def [](*args) = items[*args]
  def at(*args) = items.at(*args)
  def fetch(*args, &block) = table.fetch(*args, &block)
  def index(*args) = text.index(*args)
  def values_at(*args) = items.values_at(*args)
  def each(*args, &block) = items.each(*args, &block)
  def sample_last(*args) = counted.last(*args)
  def chained(*args) = self.items.first(*args)
end

b = Box.new
p b.last, b.last(2)
p b.first, b.first(3)
p b.take(2)
p b[1], b[1, 2]
p b.at(-1)
p b.fetch(:a), b.fetch(:z, 0), b.fetch(:q) { |k| k.to_s }
p b.index("o"), b.index("o", 5)
p b.values_at(0, 2)
b.each { |x| print x, " " }
puts
p b.sample_last, b.sample_last(2), b.reads
p b.chained, b.chained(2)
begin
  b.last(1, 2)
rescue ArgumentError => e
  p e.message
end
begin
  b.take
rescue ArgumentError => e
  p e.message
end
