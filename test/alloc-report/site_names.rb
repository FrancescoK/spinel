# The per-site report names the method that asked, not an address (#1336
# follow-up). `walk` recurses twice per level, so the C compiler keeps it out
# of line, and the String it builds is allocated in its own frame: with the
# symbol map --profile writes beside the binary that site reads `Tree#walk`.
class Tree
  def initialize(tag)
    @tag = tag
  end

  def walk(d, acc)
    return acc if d == 0
    acc << "n#{d}-#{@tag}"
    walk(d - 1, acc)
    walk(d - 1, acc) if d.odd?
    acc
  end
end

t = Tree.new(3)
total = 0
50.times { total += t.walk(6, []).size }
puts total
