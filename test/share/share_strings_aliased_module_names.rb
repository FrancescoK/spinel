# --share-strings: a constant that aliases a module names that module to a
# prepend or an extend. A module of the program's own that defines no
# method of a String Range's name, extended through its alias or through
# a chain of aliases, and a library module extended by name, do not put a
# method ahead of the Range's first: the route that hands on its endpoint
# still applies.
# spinel: gc-stress
require "forwardable"

module Listy
  def first = 1
end
module Other
  def note = 2
end
module Third
  def note3 = 3
end
Al = Other
T1 = Third
T2 = T1
class Q
  include Listy
  extend Forwardable
  extend Al
end
class P
  include Listy
  extend T2
end
p Q.new.first, P.new.first
s = String.new("a")
r = s..(+"c")
x = r.first
t = x
x << "!"
p t, s, r
