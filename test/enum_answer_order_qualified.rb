# Enumerable written with its scope, `::Enumerable` or `Object::Enumerable`,
# takes the same place in the lookup as the bare name, for include and prepend.
module Front
  def count = 61
end

class Prepending
  prepend ::Enumerable
  attr_reader :count
  def initialize; @count = 9; end
  def each; yield 1; yield 2; end
end

class PrependingScoped
  prepend Object::Enumerable
  attr_reader :count
  def initialize; @count = 9; end
  def each; yield 1; yield 2; end
end

class IncludedFirst
  include ::Enumerable
  include Front
  def each; yield 1; end
end

class IncludedLast
  include Front
  include ::Enumerable
  def each; yield 1; end
end

class ScopedLast
  include Front
  include Object::Enumerable
  def each; yield 1; end
end

p Prepending.new.count, PrependingScoped.new.count
p IncludedFirst.new.count, IncludedLast.new.count, ScopedLast.new.count
