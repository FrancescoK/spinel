# Boxed block calls keep each planned user method's result.
require "stringio"
class PlanFeed
  def each_byte
    yield 1
    :feed_done
  end
end
class PlanReopenedFeed; end
class PlanReopenedFeed
  def each_byte
    yield 2
    :reopened_done
  end
end
p [StringIO.new("a"), PlanFeed.new][ARGV.size + 1].each_byte { |b| b }
p [StringIO.new("a"), PlanReopenedFeed.new][ARGV.size + 1].each_byte { |b| b }
class StringIO
  def each_pair_line
    each_line { |line| yield line.chomp }
    :pairs
  end
end
class PlanSource
  def each_pair_line = (yield "u"; :source)
end
p [StringIO.new("b\n"), PlanSource.new][ARGV.size].each_pair_line { |line| p line }
p [StringIO.new("c\n"), PlanSource.new][ARGV.size + 1].each_pair_line { |line| p line }

# Ignoring the yielded argument keeps both block effects and the answer.
calls = 0
p [StringIO.new("a"), PlanFeed.new][ARGV.size + 1].each_byte { calls += 1 }
p [StringIO.new("a"), PlanReopenedFeed.new][ARGV.size + 1].each_byte { calls += 1 }
io = [StringIO.new("a"), PlanFeed.new][ARGV.size]
p io.each_byte { calls += 1 }.equal?(io)
p [StringIO.new("z\n"), PlanSource.new][ARGV.size].each_pair_line { calls += 1 }
p calls

# A builtin receiver beside a native class's own method answers the builtin's value.
class StringIO
  def sort_by
    lines = []
    each_line { |line| lines << line.chomp }
    lines.sort_by { |line| yield line }
  end
end
p [[3, 1, 2], StringIO.new("b\na\n")][ARGV.size].sort_by { |x| -x }
p [[3, 1, 2], StringIO.new("b\na\n")][ARGV.size + 1].sort_by { |x| x }
