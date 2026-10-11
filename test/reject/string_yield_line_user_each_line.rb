# A block parameter yielded straight into an appending proc, bound by a
# String's each_line the program defines itself: that each_line yields the
# String itself, which the caller still holds, so the append must reach it.
# Still refused, not silently applied to a copy.
# spinel: reject-thread-string
class String
  def each_line
    yield self
  end
end
class Inflated
  def initialize(data) = @data = data
  def each_line
    @data.each_line { |l| yield l }
    p @data
  end
end
out = []
mark = proc { |s| s << "*"; out << s }
Inflated.new(+"x").each_line(&mark)
p out
