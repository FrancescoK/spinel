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
# `respond_to?(name)` with a name only known at run time: the answer is
# decided at the dispatch, over the same closed set of candidate names a
# runtime-name send resolves over, with the receiver's class and the
# literal fold answering each arm. A user object raised NoMethodError for
# respond_to? itself; the receiverless form in a method was refused.
class Person
  def initialize(n) = @n = n
  def name = @n
  def check(m) = respond_to?(m)
  private
  def secret = 1
end
pe = Person.new("Ann")
names = [:name, :zzz, :upcase, :secret]
p names.map { |m| pe.respond_to?(m) }
p names.map { |m| pe.check(m) }
p names.map { |m| pe.check(m.to_s) }
p names.map { |m| "s".respond_to?(m) }
pub = [:name, :zzz, :upcase]   # (a boxed receiver's literal fold does not yet weigh visibility)
x = [pe, nil, "s"].first
p pub.map { |m| x.respond_to?(m) }
y = [pe, nil, "s"].last
p pub.map { |m| y.respond_to?(m) }
p names.map { |m| nil.respond_to?(m) }
