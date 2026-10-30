# `map.with_index(1) { }` over a boxed receiver whose class may define
# `map` and `with_index` of its own: the class-id dispatch's builtin arm
# declares its slot by the call's own type (an array of Strings here),
# and the enumerator emitter answered the kept box, which the C could
# not assign to it.
class Items
  def map = ["q"]
  def with_index(start = 0) = ["w#{start}"]
end
class Fallbacks
  def split(sep) = Items.new
end
class Err
  def initialize(s) = @src = s
  def annotated
    @src.split("\n").map.with_index(1) { |line, index|
      indentation = " " * 4
      "#{index}:#{indentation}#{line}"
    }
  end
end
fb = Fallbacks.new
p fb.split("x").map
p fb.split("x").with_index(2)
p Err.new("a\nb").annotated
p Err.new(ARGV.empty? ? "c\nd" : fb).annotated
