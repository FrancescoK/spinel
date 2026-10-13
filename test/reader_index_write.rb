# `all[k] = v` through a reader of the class's own ivar types that ivar's
# Hash as a store into @all does (a registry with `def all =
# @all ||= {}` beside `def register(addon) = all[addon.id] = addon`), so an
# Enumerable call over its values has its definition. A subclass that
# overrides the reader keeps the store going through its own.
class Registry
  class << self
    def all = @all ||= {}
    def register(k, v) = all[k] = v
    def enabled = %w[a nope b].filter_map { |id| all[id] }
  end
end

class Book
  attr_reader :tags

  def initialize(n)
    @index = {}
    @n = n
  end

  def index = @index
  def store(k, v) = index[k] = v
  def parts = [@n, @n * 2]
end

class Shelf
  attr_reader :slots

  def initialize = @slots = {}
  def put(k, v) = slots[k] = v
end

class Base
  def initialize = @box = {}
  def box = @box
  def put(k, v) = box[k] = v
end

class Other < Base
  def box = (@other ||= {})
end

Registry.register("a", Book.new(1))
Registry.register("b", Book.new(2))
p Registry.enabled.flat_map(&:parts)
p Registry.all.values.sum { |b| b.parts.first }

b = Book.new(3)
p(b.store(:x, 5))
p b.index.values.map { |v| v + 1 }

s = Shelf.new
s.put("k", [1, 2])
p s.slots.values.flat_map { |a| a }

o = Other.new
o.put(:z, 9)
p o.box, o.instance_variable_get(:@box)
