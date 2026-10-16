# an iterator that takes no argument, handed a splat without a block: an
# empty splat answers what the call without one does (an Enumerator that
# enumerates the same values), and one that is not empty raises CRuby's
# ArgumentError

class C
  def initialize(a) = (@a = a)
  def each_with_index(*args, &blk) = @a.each_with_index(*args, &blk)
end

c = C.new([1, 2])
p c.each_with_index.class
p c.each_with_index.to_a

def e(a, *s) = a.each(*s)
p e([3, 4]).class
p e([3, 4]).to_a
p((e([3], 1) rescue $!.message))
def eh(h, *s) = h.each(*s)
p eh({ k: 5 }).to_a
def er(r, *s) = r.each(*s)
p er(1..3).to_a

def m(a, *s) = a.map(*s)
p m([1, 2]).with_index.to_a
p((m([1], :x, :y) rescue $!.message))

def u(a, *s) = a.uniq(*s)
p u([1, 1, 2])
