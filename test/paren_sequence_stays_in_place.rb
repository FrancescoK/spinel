# A parenthesized sequence runs where it stands when its last expression
# hands a String to a parameter that is changed in place. Such a String gets
# a handle where it is handed over, and the temp that holds the handle is
# declared ahead of the statement. That declaration runs nothing, so the
# sequence stays behind the operands written before it: each line here
# reads `s` first and assigns it in a sequence further on.
class Pair
  attr_reader :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end
  def self.late(s)
    return s, (s = "bb"; new("x", "t").x)
  end
  def self.late_two(s)
    return s, (s = "bb"; new("x", "2").x + new("y", "3").y)
  end
  def self.late_text(s) = "#{s}|#{(s = "bb"; new("x", "2").x + new("y", "3").y)}"
  # Written ahead of the read, the new value is the one read.
  def self.sum(s) = (s = "bb") + new(s, "t").x
  def self.text(s) = "#{(s = "bb")}-#{new(s, "t").x}"
  def self.two(s)
    return (s = "bb"), new(s, "t").x
  end
end

d = Pair.new(+"w", +"v")
d.x << "z"
d.y << "z"
p [d.x, d.y]
p Pair.late("a")
p Pair.late_two("a")
p Pair.late_text("a")
p Pair.sum("a"), Pair.text("a"), Pair.two("a")
