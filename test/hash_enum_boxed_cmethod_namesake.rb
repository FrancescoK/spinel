# `r.each_pair` (or each_key / each_value) without a block on a value that
# is a Hash or a program object, in a program where some class also has a
# class method of the name: the Hash answers its Enumerator boxed once.
# The class method made the builtin's answer boxed, and both the Hash's
# blockless emitter and the dispatch's Hash face boxed the Enumerator, a
# boxed value boxed again, which did not compile.

class Parser
  def self.each_pair(s) = s
  def self.each_key = nil
end
class Req
  def each_pair = self
  def each_key = :keys
end

def pairs(r) = r.each_pair
def keys(r) = r.each_key

p pairs(Req.new).class
p pairs({ a: 1 }).to_a
p keys(Req.new)
p keys({ b: 2 }).to_a
p Parser.each_pair(:s)
