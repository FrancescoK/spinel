module Named
  def named = 1
end

class V
  include Named
  def a = 1
  private def c = 3
  protected def pr = 4
  attr_reader :r
  attr_writer :w
  alias b a
end

class Sub < V
  def s = 5
end

class Bag
  include Enumerable
  def each
    yield 1
  end
end

def rt(o, sym, all = false) = o.respond_to?(sym, all)

p rt(V.new, :a)
p rt(V.new, :zz)
p rt(V.new, :c)
p rt(V.new, :c, true)
p rt(V.new, :pr)
p rt(V.new, :pr, true)
p rt(V.new, :r)
p rt(V.new, :w=)
p rt(V.new, :w)
p rt(V.new, :b)
p rt(V.new, :named)
p rt(V.new, :s)
p rt(Sub.new, :s)
p rt(Sub.new, :a)
p rt(V.new, "a")
p rt(V.new, :to_s)
p rt(V.new, :initialize)
p rt(V.new, :initialize, true)
p rt(Bag.new, :map)
p V.new.respond_to?([:a].first)
p rt([V.new, 1].first, :a)
p rt([1, V.new].first, :a)
p rt([1, V.new].first, :even?)
p "str".respond_to?(["up", "case"].join)
p 1.respond_to?([:zz].first)
