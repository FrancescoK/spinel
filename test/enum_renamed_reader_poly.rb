# A receiver known only at run time may be an instance of a class whose reader
# is named detect or collect_concat: that class answers its ivar, the others
# (an Enumerable class, an Array, a Hash) the Enumerable method, whichever of
# them the value is. The builtin copies' names (find, flat_map) are not the
# program's.
class Reader
  attr_reader :detect, :collect_concat
  def initialize; @detect = 7; @collect_concat = 8; end
end

class Walked
  include Enumerable
  def each; yield 3; yield 1; end
end

objs = [Reader.new, Walked.new]
p objs.map { |o| o.detect { |v| v < 3 } }
p objs.map { |o| o.collect_concat { |v| [v] } }
mixed = [Reader.new, [3, 1]]
p mixed.map { |o| o.detect { |v| v < 3 } }
p mixed.map { |o| o.collect_concat { |v| [v] } }
hashes = [Reader.new, {a: 1}]
p hashes.map { |o| o.detect { |k, v| v == 1 } }
p mixed.map { |o| o.is_a?(Reader) ? o.detect : o.detect { |v| v < 3 } }
p [Walked.new, [4, 1]].map { |o| o.detect { |v| v < 3 } }
