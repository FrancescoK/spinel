# `x ||= v` in value position, inside a block that becomes a proc of its
# own and captures x, where x holds a value of any type: Date's
# `(today ||= Date.today).year` in its fragment completion. The write and
# its truth test named the method's own local, which the proc does not
# have, instead of the captured slot, so the C did not compile. A Boolean
# or Symbol local took the same path.
class Syms
  def initialize(*s) = @s = s
  def each(&blk) = @s.each(&blk)
end

def pick(n) = [:d, 2025][n]

def fill(a)
  first = nil
  out = []
  a.each { |x| out << (first ||= pick(x)) }
  [out, first]
end

def flag_once(a)
  seen = false
  hits = []
  a.each { |x| hits << (seen ||= x > 1) }
  [hits, seen]
end

def tag_once(a)
  tag = nil
  a.each { |x| tag ||= x }
  tag
end

p fill([[0, 1], Syms.new(1)][ARGV.size])
p fill(Syms.new(1, 0))
p flag_once([[1, 2, 0], Syms.new(0)][ARGV.size])
p flag_once(Syms.new(3, 0))
p tag_once([[:a, :b], Syms.new(:c)][ARGV.size])
