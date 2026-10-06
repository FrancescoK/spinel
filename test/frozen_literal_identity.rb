# Equal frozen string literals are one object, as in CRuby with
# --enable-frozen-string-literal: the same text in two methods, a literal
# re-evaluated in a loop and an adjacent-literal fold all give the object
# the plain literal does. An interpolated string is built each time.
def tag_a = "tag"
def tag_b = "tag"

p tag_a.equal?(tag_b)
p tag_a.object_id == tag_b.object_id
p tag_a.frozen?
p "tag".equal?(tag_a)

ids = []
3.times { ids << "tag".object_id }
p ids.uniq.size
p ids[0] == tag_b.object_id

# keyed by identity: every occurrence lands on one key
by_id = {}
by_id["k".object_id] = 1
by_id["k".object_id] = 2
by_id[tag_a.object_id] = 3
by_id[tag_b.object_id] = 4
p by_id.size

p ("ta" "g").equal?(tag_a)
p ("ta" "g").equal?("t" "ag")

n = 7
p "#{n}".equal?("#{n}")
p "n#{n}".frozen?

p "".equal?("")
p "été".equal?("été")
p "a\0b".equal?("a\0b")
p "a\0b".bytesize
p "x".equal?("y")

class Holder
  def initialize
    @name = "tag"
  end
  attr_reader :name
end
p Holder.new.name.equal?(Holder.new.name)
p Holder.new.name.equal?(tag_a)
