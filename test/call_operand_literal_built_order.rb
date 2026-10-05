# An Array or Hash literal operand is built in the statement's prelude, ahead
# of the call. An operand to its left that runs code ran after it: a literal
# that reads a value read it too early, and a parenthesized operand whose
# value builds one ran its statements first. CRuby runs the operands in the
# order they are written.

class Box
  attr_accessor :v
  def initialize = (@v = nil)
end

def show(log)
  p log
  log.clear
end

def t(k)
  log = []
  p [1].union((log << :a0; [3]), (log << :a1; [2]))
  show(log)
  p [1].push((log << :a0; 1), (log << :a1; [2]))
  show(log)
  p([1].union((log << :a0; nil), (log << :a1; [2]))) rescue p $!
  show(log)
  p [1].push((log << :a0; 1), [log.size])
  p [1].push((log << :a1; 1), {n: log.size})
  p [1].fill((log << :a2; 9), (log << :a3; [1].size))
  show(log)
  x = 0
  p [1].push((x = 5; 1), [x])
  h = {}
  h[(log << :b0; 1)] = [log.size]
  h.store((log << :b1; 2), [log.size])
  y = (h[(log << :b2; 3)] = [log.size])
  p h, y
  a = [0, 0]
  a[(log << :b3; 1)] = {n: log.size}
  p a
  show(log)
  o = Box.new
  (log << :c0; o).v = [log.size]
  p o.v
  show(log)
end

t(ARGV.size)
