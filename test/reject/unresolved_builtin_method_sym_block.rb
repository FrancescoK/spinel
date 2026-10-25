# spinel: reject-subclass: Array#drop_while on a value typed as Array, a call no route of the compiler took
# An Array's own method given `&:name`, on the answer of a method that
# returns a local assigned only `[]` (an Array the analysis types only
# after its main pass): no route of the compiler takes the call, so it is
# refused at compile time, naming the method, rather than raising
# NoMethodError for a method CRuby calls.
class Item
  def initialize(s) = @s = s
  def label = @s
end

def none_yet
  out = []
  out
end

p none_yet.drop_while(&:label)
