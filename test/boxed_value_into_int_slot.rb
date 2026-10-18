# Values the analysis holds boxed or leaves untyped, into slots typed
# Integer: the offset of with_index, a spliced block's nil tail, and a
# yield argument no class answers (it raises NoMethodError first).

# with_index(n) with an offset known only at run time
class Body
  def initialize(s, l) = (@s = s; @l = l)
  def source = @s
  def first_line = @l
end
class Other
  def source = "z\n"
  def first_line = ARGV.size > 3 ? "q" : 10
end
def numbered(body)
  src = "#{body.source}"
  src.each_line.with_index(body.first_line).map { |line, n| "#{n}: #{line}" }
end
puts numbered(Body.new("a\nb\n", 3))
puts numbered(Other.new)

# a block spliced into a yield, `next`-ing or ending in a method whose
# value is nil (its body returns early)
class Rng
  def initialize(b, e) = (@b = b; @e = e)
  attr_reader :b, :e
  def begin_pos = @b
end
class Checker
  def initialize = (@hits = []; @keys = {})
  attr_reader :hits
  def report(range, message: nil)
    key = range.b * 100 + range.e
    return if @keys.key?(key)
    @keys[key] = true
    @hits << [range.b, range.e, message]
    nil
  end
  def ignored?(pos) = pos == 7
  def extra_space_range(a, b)
    return if b <= a
    yield Rng.new(a, b)
  end
  def check_other(a, b)
    return false if a < 0
    extra_space_range(a, b) do |range|
      next if ignored?(range.begin_pos)
      report(range, message: "x")
    end
  end
end
c = Checker.new
p c.check_other(1, 3)
p c.check_other(7, 9)
p c.check_other(-1, 2)
p c.check_other(1, 3)
p c.hits

# yield arguments from a method no class answers
class Node
  def initialize(t) = @t = t
end
class Escapes
  def each_escape(node)
    yield("z", 0, false) if node.nil?
    node.parsed_tree&.traverse&.reduce(0) do |depth, (event, expr)|
      yield(expr.text[1], expr.ts, !depth.zero?) if expr.type == :escape
      depth
    end
  end
  def first(node)
    each_escape(node) { |ch, index, within| return [ch, index - 1, within] }
    nil
  end
end
p Escapes.new.first(nil)
begin
  p Escapes.new.first(Node.new(1))
rescue NoMethodError => e
  p e.class
end
