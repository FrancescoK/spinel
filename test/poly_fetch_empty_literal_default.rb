# fetch(key, default) on a boxed Hash answers the default for a missing key
# when the default is an empty `[]` or `{}`. Such a literal has no type of
# its own, so the dispatch holds it boxed in its temp; the arms boxed that
# temp again by the literal's type, which ran it for effect and answered
# nil.
require "json"

h = JSON.parse('{"title":"hello","tagList":["a"]}')
p h.fetch("missing", [])
p h.fetch("missing", {})
p h.fetch("tagList", [])
p h.fetch("title", {})
p h.fetch("missing", [1])
p h.fetch("missing") { [] }

def tag_list(input) = input.fetch("tagList", [])
p tag_list(h)
p tag_list(JSON.parse('{"title":"no tags"}'))

# a Symbol key, on a Hash literal read out of an Array
s = [{ a: 1 }, 1][0]
p s.fetch(:missing, [])
p s.fetch(:missing, {})

# a key known only at run time, on the JSON Hash
k = ["missing", 1][0]
p h.fetch(k, [])

# a Hash of String and Symbol keys
mixed = [{ "a" => 1, a: 2 }, 0][0]
p mixed.fetch("missing", [])
p mixed.fetch(:missing, {})
p mixed.fetch("a", [])

# a receiver of no single type: a Hash or an Array
def pick(i) = i.zero? ? { "k" => 1 } : [1, 2]
p pick(0).fetch("k", [])
p pick(0).fetch("missing", [])
p pick(1).fetch(5, {})

# a key whose hash runs Ruby code that collects: the default is held
# across the lookup, and comes back as itself
class CollectingKey
  attr_reader :a
  def initialize(a) = (@a = a)
  def hash
    GC.start
    junk = []
    64.times { |k| junk << ["j#{k}"]; junk << { k => k } }
    @a
  end
  def eql?(o) = o.is_a?(CollectingKey) && @a == o.a
end
g = [{ CollectingKey.new(1) => 1, "s" => 2 }, 1][0]
ck = [CollectingKey.new(9), 1][0]
d = g.fetch(ck, [])
d << :x
p d
e = g.fetch(ck, {})
e[:y] = 1
p e

# the answered default is a usable Array
tags = h.fetch("other", [])
tags << "x"
p tags
