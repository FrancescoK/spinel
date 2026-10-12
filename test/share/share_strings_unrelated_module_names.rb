# --share-strings: a module of the program's own that defines first, min,
# take or sort, included into a class of its own and never prepended or
# extended, cannot answer a String Range's or an Array's method of that
# name: the routes and facts that hand on a Range's endpoint or a fresh
# Array's elements still apply. They stood aside for any module defining
# the name, and these programs were refused.
# spinel: gc-stress

module Listy
  def first = 1
  def min = 2
  def sort = 3
  def take(n) = 4
end
class Q
  include Listy
end
p Q.new.first
s = String.new("a")
r = s..(+"c")
def y(q) = yield(q.first)
y(r) { |v| v << "!" }
p r
m = r.min
m2 = m
m << "?"
p m2, r
k = r.take(1)[0]
k << "%"
p k, s
w = "b a".split.sort[0]
w2 = w
w << "#"
p w2
