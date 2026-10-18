# detect and collect_concat are find and flat_map under another name for
# Enumerable, but a reader of a class named so answers the call written with
# that name: a class that does not include Enumerable and one that does. A
# receiver known only at run time keeps the builtin's detect while no class it
# may be has the reader.
class X
  attr_reader :detect, :collect_concat, :find_all
  def initialize; @detect = 1; @collect_concat = 2; @find_all = 3; end
end
class Y
  include Enumerable
  def each; yield 3; yield 1; yield 4; end
  def inn = detect { |v| v > 3 }
end
y = Y.new
p y.detect { |v| v < 3 }
p y.find { |v| v < 3 }
p y.collect_concat { |v| [v, v] }
p y.flat_map { |v| [v] }
p y.find_all { |v| v > 1 }
p y.inn
x = X.new
p [x.detect, x.collect_concat, x.find_all]
p [3, 1].detect { |v| v < 3 }
p [[1], [2]].collect_concat { |v| v }
p({a: 1}.detect { |k, v| v == 1 })
z = (1..5).detect { |v| v > 2 }
p z

class Unused
  attr_reader :detect, :collect_concat
  def initialize; @detect = 1; @collect_concat = 2; end
end

class Walked
  include Enumerable
  def each; yield 3; yield 1; end
end

objs = [Walked.new, [4, 1]]
p objs.map { |o| o.detect { |v| v < 3 } }
p objs.map { |o| o.collect_concat { |v| [v, v] } }
