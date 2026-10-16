# A superclass written as a constant that holds a class (`Impl = Base`,
# concurrent-ruby's `class Map < MapImplementation`) is that class: the
# subclass inherits its methods. The constant named no class of its own,
# so the parent was left unset with no word, and a call of an inherited
# method raised NoMethodError at run time.
class Base
  def hi = "hi"
end

Impl = Base
Again = Impl

class Sub < Impl
  def own = "own"
end

class Deeper < Again; end

module Concurrent
  class MriMapBackend
    def initialize
      @h = {}
    end

    def [](k) = @h[k]

    def []=(k, v)
      @h[k] = v
    end
  end

  MapImplementation = MriMapBackend

  class Map < MapImplementation
    def fetch_or_store(k) = self[k] || (self[k] = yield(k))
  end
end

p Sub.new.hi, Sub.new.own, Sub.superclass, Deeper.new.hi
m = Concurrent::Map.new
p m.fetch_or_store(:a) { 1 }, m[:a]
