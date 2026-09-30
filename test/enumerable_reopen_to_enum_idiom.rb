# A method added to Enumerable itself with the blockless-branch idiom --
# activesupport's index_by / index_with, `to_enum(:index_by) { size if
# respond_to?(:size) }` when no block is given -- is reached through a user
# class that includes Enumerable. The module's own copy of the method has no
# receiver to iterate, so the to_enum rewrite must not synthesize a generator
# on the module (whose body would compile that copy, and refuse its bare
# `each`); the includer's copy gets its own.

module Enumerable
  def index_by
    if block_given?
      result = {}
      each { |elem| result[yield(elem)] = elem }
      result
    else
      to_enum(:index_by) { size if respond_to?(:size) }
    end
  end

  def index_with(default = (no_default = true))
    if block_given?
      result = {}
      each { |elem| result[elem] = yield(elem) }
      result
    elsif no_default
      to_enum(:index_with) { size if respond_to?(:size) }
    else
      result = {}
      each { |elem| result[elem] = default }
      result
    end
  end
end

class Bag
  include Enumerable
  def initialize(*xs) = @xs = xs
  def each(&b) = @xs.each(&b)
end

bag = Bag.new("a", "bb", "ccc")
p bag.index_by(&:size)
p bag.index_with { |s| s.upcase }
p bag.index_with(0)
p bag.index_by.to_a
p bag.index_with.map { |s| s * 2 }
